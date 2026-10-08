package settings

func stricterLimit(chosen *int, serverLimit int) int {
	if chosen == nil {
		return serverLimit
	}
	if serverLimit == 0 {
		return *chosen
	}
	if *chosen == 0 || *chosen > serverLimit {
		return serverLimit
	}
	return *chosen
}

func atMost(chosen *int, serverLimit int) int {
	if chosen == nil || *chosen > serverLimit {
		return serverLimit
	}
	return *chosen
}

func exceedsLimit(chosen, serverLimit int) bool {
	return serverLimit != 0 && (chosen == 0 || chosen > serverLimit)
}
