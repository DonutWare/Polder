package emails

import (
	"fmt"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/users"
)

const (
	timeLayout     = "Mon 2 Jan 2006, 15:04 MST"
	resetCodeHours = 1
)

func preferencesFooter(brand Brand, topic string) string {
	return fmt.Sprintf("You can turn off %s emails in %s under Settings → Notifications.", topic, brand.Name)
}

func openAction(brand Brand) *Action {
	if brand.PublicURL == "" {
		return nil
	}
	return &Action{Label: "Open " + brand.Name, URL: brand.PublicURL}
}

func greeting(user users.User) string {
	return "Hi " + user.ShownName() + ","
}

func passwordResetContent(brand Brand, user users.User, code string) Content {
	return Content{
		Subject:   fmt.Sprintf("Your %s reset code: %s", brand.Name, code),
		Preheader: fmt.Sprintf("Use %s to choose a new password. It works for %d hour.", code, resetCodeHours),
		Heading:   "Reset your password",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("Someone asked to reset the password of your %s account %s. Enter this code under “Forgot password?” in %s to choose a new password. We never send reset links, so don't trust an email that asks you to click one.", brand.Name, user.Username, brand.Name),
		},
		Code: &Code{
			Value: code,
			Note:  fmt.Sprintf("Works once, for %d hour", resetCodeHours),
		},
		Closing: []string{"If you didn't ask for this, you can ignore this email. Your password stays the same, and nobody can use the code without access to this inbox."},
	}
}

func passwordChangedContent(brand Brand, user users.User, change PasswordChange, when time.Time) Content {
	who := ""
	if change.ByAdministrator {
		who = " by an administrator"
	}
	details := []Detail{{Label: "Time", Value: when.UTC().Format(timeLayout)}}
	if change.Address != "" {
		details = append(details, Detail{Label: "IP address", Value: change.Address})
	}
	return Content{
		Subject:   fmt.Sprintf("Your %s password was changed", brand.Name),
		Preheader: "You've been signed out on your other devices.",
		Heading:   "Your password was changed",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("The password of your account %s was just changed%s. You've been signed out on your other devices.", user.Username, who),
		},
		Details: details,
		Closing: []string{"If this wasn't you, contact your administrator right away."},
	}
}

func emailChangedContent(brand Brand, user users.User, newAddress string) Content {
	return Content{
		Subject:   fmt.Sprintf("Your %s email address was changed", brand.Name),
		Preheader: "Emails will now go to " + newAddress + ".",
		Heading:   "Your email address was changed",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("The email address of your account %s was changed to %s. Emails from %s go there from now on.", user.Username, newAddress, brand.Name),
		},
		Closing: []string{"If you didn't make this change, change your password and contact your administrator."},
	}
}

func newSignInContent(brand Brand, user users.User, signIn SignIn) Content {
	return Content{
		Subject:   fmt.Sprintf("New sign-in to your %s account", brand.Name),
		Preheader: "Signed in from " + signIn.Address + " on " + signIn.Device + ".",
		Heading:   "New sign-in from " + signIn.Address,
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("Your account %s just signed in from an address it hasn't used before.", user.Username),
		},
		Details: []Detail{
			{Label: "Device", Value: signIn.Device},
			{Label: "IP address", Value: signIn.Address},
			{Label: "Time", Value: signIn.At.UTC().Format(timeLayout)},
		},
		Action:  openAction(brand),
		Closing: []string{"If this was you, there's nothing to do. If it wasn't, change your password right away."},
		Footer:  preferencesFooter(brand, "security"),
	}
}

func quotaContent(brand Brand, user users.User, level int) Content {
	used, quota := FormatBytes(user.UsedBytes), FormatBytes(user.QuotaBytes)
	content := Content{
		Subject:   fmt.Sprintf("You've used %d%% of your %s storage", level, brand.Name),
		Preheader: fmt.Sprintf("%s of %s used.", used, quota),
		Heading:   "Your storage is almost full",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("You've used %s of your %s. Once it's full, uploads and syncing stop.", used, quota),
		},
		Action:  openAction(brand),
		Closing: []string{"Empty the trash or remove earlier versions of files to make room, or ask your administrator for more space."},
		Footer:  preferencesFooter(brand, "storage"),
	}
	if level >= fullLevel {
		content.Subject = fmt.Sprintf("Your %s storage is full", brand.Name)
		content.Heading = "Your storage is full"
		content.Paragraphs[1] = fmt.Sprintf("You've used %s of your %s. New uploads and syncing fail until you make room.", used, quota)
	}
	return content
}

func shareContent(brand Brand, user users.User, notice activity.ShareNotice) Content {
	kind := "file"
	if notice.IsDir {
		kind = "folder"
	}
	sharer := notice.OwnerName
	if sharer == "" {
		sharer = notice.Owner
	}
	via := ""
	switch {
	case notice.Group != "":
		via = " through the group " + notice.Group
	case notice.Server != "":
		via = " from " + notice.Server
	}
	var details []Detail
	if notice.Note != "" {
		details = append(details, Detail{Label: "Note", Value: notice.Note})
	}
	return Content{
		Subject:    fmt.Sprintf("%s shared “%s” with you", sharer, notice.Name),
		Preheader:  fmt.Sprintf("A %s shared with you on %s.", kind, brand.Name),
		Heading:    fmt.Sprintf("%s shared a %s with you", sharer, kind),
		Paragraphs: []string{greeting(user), fmt.Sprintf("%s shared the %s “%s” with you%s.", sharer, kind, notice.Name, via)},
		Details:    details,
		Action:     openAction(brand),
		Footer:     preferencesFooter(brand, "sharing"),
	}
}

func accountCreatedContent(brand Brand, user users.User, resetAvailable bool) Content {
	paragraphs := []string{
		greeting(user),
		fmt.Sprintf("An account was created for you on %s. Your username is %s, and your administrator can tell you your password.", brand.Name, user.Username),
	}
	if resetAvailable {
		paragraphs = append(paragraphs, "You can also choose your own password with “Forgot password?” on the sign-in screen.")
	}
	var details []Detail
	if brand.PublicURL != "" {
		details = append(details, Detail{Label: "Server", Value: brand.PublicURL})
	}
	details = append(details, Detail{Label: "Username", Value: user.Username})
	return Content{
		Subject:    "Welcome to " + brand.Name,
		Preheader:  "Your account is ready.",
		Heading:    "Welcome to " + brand.Name,
		Paragraphs: paragraphs,
		Details:    details,
		Action:     openAction(brand),
	}
}

func testContent(brand Brand) Content {
	return Content{
		Subject:   "Test email from " + brand.Name,
		Preheader: "The mail server settings work.",
		Heading:   "Your mail server works",
		Paragraphs: []string{
			fmt.Sprintf("This test shows that %s can send email. Password resets, sign-in alerts, storage warnings and shares are sent like this.", brand.Name),
		},
		Action: openAction(brand),
	}
}

func FormatBytes(size int64) string {
	const unit = 1024
	if size < unit {
		return fmt.Sprintf("%d B", size)
	}
	value, exponent := float64(size), 0
	for value >= unit && exponent < 5 {
		value /= unit
		exponent++
	}
	return fmt.Sprintf("%.1f %cB", value, "KMGTP"[exponent-1])
}
