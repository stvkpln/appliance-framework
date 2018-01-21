function Get-FormattedMessage {
	Param (
		[String]$Message
	)
	$date = (Get-Date).ToString("M/dd/yyyy h:mm:ss tt")
	$date + " " + $Message
}
