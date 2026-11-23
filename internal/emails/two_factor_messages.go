package emails

import (
	"fmt"
	"time"

	"polder-server/internal/users"
)

const dateLayout = "Monday 2 January 2006"

func twoFactorSetupSteps(brand Brand) string {
	return fmt.Sprintf("Open %s, go to Settings → Account → Two-factor authentication and scan the QR code with an authenticator app such as Aegis, 2FAS, Google Authenticator or 1Password.", brand.Name)
}

func twoFactorRequiredContent(brand Brand, user users.User, deadline time.Time) Content {
	due := deadline.UTC().Format(dateLayout)
	return Content{
		Subject:   fmt.Sprintf("Set up two-factor authentication for %s before %s", brand.Name, due),
		Preheader: "Your administrator now requires a code from an authenticator app when you sign in.",
		Heading:   "Two-factor authentication is now required",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("Your administrator requires everyone on %s to use two-factor authentication. Signing in to your account %s will then need your password and a code from an authenticator app.", brand.Name, user.Username),
			twoFactorSetupSteps(brand),
		},
		Details: []Detail{{Label: "Set up before", Value: deadline.UTC().Format(timeLayout)}},
		Action:  openAction(brand),
		Closing: []string{"After that date you can still sign in, but you'll have to set it up before you can do anything else."},
	}
}

func twoFactorReminderContent(brand Brand, user users.User, deadline time.Time, now time.Time) Content {
	left := deadline.Sub(now)
	when := "in " + daysLeft(left)
	return Content{
		Subject:   fmt.Sprintf("Reminder: set up two-factor authentication for %s %s", brand.Name, when),
		Preheader: "Your account still has no authenticator app set up.",
		Heading:   "Two-factor authentication is due " + when,
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("Your account %s still needs two-factor authentication. It's required by %s.", user.Username, deadline.UTC().Format(timeLayout)),
			twoFactorSetupSteps(brand),
		},
		Action:  openAction(brand),
		Closing: []string{"After that date you can still sign in, but you'll have to set it up before you can do anything else."},
	}
}

func daysLeft(left time.Duration) string {
	days := int(left.Round(time.Hour).Hours()+23) / 24
	if days <= 1 {
		return "1 day"
	}
	return fmt.Sprintf("%d days", days)
}

func twoFactorEnabledContent(brand Brand, user users.User, when time.Time) Content {
	return Content{
		Subject:   fmt.Sprintf("Two-factor authentication is on for your %s account", brand.Name),
		Preheader: "Signing in now also needs a code from your authenticator app.",
		Heading:   "Two-factor authentication is on",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("Signing in to your account %s now needs your password and a code from your authenticator app. Keep your recovery codes somewhere safe: they're the way back in if you lose your phone.", user.Username),
		},
		Details: []Detail{{Label: "Time", Value: when.UTC().Format(timeLayout)}},
		Closing: []string{"If you didn't do this, change your password and contact your administrator right away."},
		Footer:  preferencesFooter(brand, "security"),
	}
}

func twoFactorDisabledContent(brand Brand, user users.User, byAdministrator bool, when time.Time) Content {
	what := fmt.Sprintf("Two-factor authentication was turned off for your account %s. Signing in now only needs your password.", user.Username)
	if byAdministrator {
		what = fmt.Sprintf("An administrator reset two-factor authentication for your account %s and signed you out everywhere. You can set it up again under Settings → Account.", user.Username)
	}
	return Content{
		Subject:    fmt.Sprintf("Two-factor authentication was turned off for your %s account", brand.Name),
		Preheader:  "Your account no longer asks for a code from an authenticator app.",
		Heading:    "Two-factor authentication is off",
		Paragraphs: []string{greeting(user), what},
		Details:    []Detail{{Label: "Time", Value: when.UTC().Format(timeLayout)}},
		Closing:    []string{"If you didn't expect this, change your password and contact your administrator right away."},
	}
}

func recoveryCodeUsedContent(brand Brand, user users.User, remaining int, signIn SignIn) Content {
	return Content{
		Subject:   fmt.Sprintf("A recovery code was used to sign in to %s", brand.Name),
		Preheader: fmt.Sprintf("%d recovery codes left.", remaining),
		Heading:   "A recovery code was used",
		Paragraphs: []string{
			greeting(user),
			fmt.Sprintf("Your account %s just signed in with one of its recovery codes instead of a code from the authenticator app. You have %d left; you can make new ones under Settings → Account.", user.Username, remaining),
		},
		Details: []Detail{
			{Label: "Device", Value: signIn.Device},
			{Label: "IP address", Value: signIn.Address},
			{Label: "Time", Value: signIn.At.UTC().Format(timeLayout)},
		},
		Closing: []string{"If this wasn't you, change your password and contact your administrator right away."},
	}
}
