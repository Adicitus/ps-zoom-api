function New-ZoomAPIMeeting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [String]$UserId,

        # Main Paramaters
        [Parameter(Mandatory=$true)]
        [String]$Title,
        [ValidateSet("Instant", "Scheduled", "RecurringWithoutFixedtime", "RecurringWithFixedtime")]
        [Parameter(Mandatory=$false, HelpMessage="Type of Meeting. (Default: Instant)")]
        [String]$Type="Instant",
        [Parameter(Mandatory=$false)]
        [SecureString]$Password,
        [Parameter(Mandatory=$false, HelpMessage="Zoom TimeZone. List found here: https://marketplace.zoom.us/docs/api-reference/other-references/abbreviation-lists#timezones (Default: UTC)")]
        [String]$TimeZone="UTC",
        [Parameter(Mandatory=$false, HelpMessage="Meeting start time, only used for Scheduled meetings and recurring meetings with fixed time.")]
        [datetime]$StartTime,
        [Parameter(Mandatory=$false, HelpMessage="Meeting duration (in minutes). Used for Scheduled Meetings only.")]
        [timespan]$Duration,
        [Parameter(Mandatory=$false)]
        [String]$Description,
        [Parameter(Mandatory=$false, HelpMessage="User ID or email for another user that this meeting should be scheduled for (must be a user in the same account).")]
        [String]$ScheduleFor,

        # Recurrence Configuration:
        [ValidateSet("Daily", "Weekly", "Monthly")]
        [Parameter(Mandatory=$false, HelpMessage="Type of schedule to use when defining recurrence.")]
        [String]$RecurrenceType,
        [Parameter(Mandatory=$false, HelpMessage="Interval between meetings (e.g. if the RecurrenceType is weekly, an interval of 2 produces a bi-weekly schedule).")]
        [int]$RecurrenceRepeatInterval,
        [Parameter(Mandatory=$false, HelpMessage="The days of the week that the meeting should occur on. English weekday names or integers acepted (Sunday=1, Saturday=7). Only used if RecurrenceType is 'Weekly'.")]
        [array]$RecurrenceWeekDays,
        [ValidateRange(1, 31)]
        [Parameter(Mandatory=$false, HelpMessage="The day of the month that the meeting should occur on. Only used if RecurrenceType is 'Monthly'.")]
        [int]$RecurrenceMonthlyDay,
        [ValidateSet("First", "Second", "Third", "Fourth", "Last")]
        [Parameter(Mandatory=$false, HelpMessage="The week of the month that the meeting should occur on. Only used if RecurrenceType is 'Monthly', RecurrenceMontlyWeekDay must also be specified.")]
        [int]$RecurrenceMonthlyWeek,
        [Parameter(Mandatory=$false, HelpMessage="The days of the week that the meeting should occur on. English weekday names or integers acepted (Sunday=1, Saturday=7). Only used if RecurrenceType is 'Monthly' and 'RecurrenceMonthlyWeek' is specified.")]
        [array]$RecurrenceMonthlyWeekDays,
        [ValidateRange(1, 50)]
        [Parameter(Mandatory=$false, HelpMessage="How many times the meeting should recur before it is cancelled. Cannot be combined with 'RecurrenceEndDate'.")]
        [int]$RecurrenceMaxNumber,
        [Parameter(Mandatory=$false, HelpMessage="Final date that the meeting can recur before it is cancelled. Cannot be combined with 'RecurrenceMaxNumber'.")]
        [datetime]$RecurrenceEndDate,

        # Settings:
        [Parameter(Mandatory=$false, HelpMessage="Start video when the host joins the meeting.")]
        [bool]$HostVideo,
        [Parameter(Mandatory=$false, HelpMessage="Start video when the participants join the meeting.")]
        [bool]$ParticipantVideo,
        [Parameter(Mandatory=$false, HelpMessage="Allow participants to join the the meeting before the host starts the meeting. Only used for scheduled or recurring meetings.")]
        [bool]$AllowJoinBeforeHost,
        [Parameter(Mandatory=$false, HelpMessage="Start video when the participants join the meeting.")]
        [bool]$MuteOnJoin,
        [Parameter(Mandatory=$false, HelpMessage="Add watermark when viewing a shared screen.")]
        [bool]$AddWatermark,
        [ValidateSet("AutomaticallyApprove", "ManuallyApprove", "NoRegistrationRequired")]
        [Parameter(Mandatory=$false, HelpMessage="Enable registration and set approval policy for new registrations. (Default: NoRegistrationRequired)")]
        [string]$ApprovalType,
        [ValidateSet("OnceIncludeAll", "ForeachOccurence", "OnceSelective")]
        [Parameter(Mandatory=$false, HelpMessage="Registration Type. Used for recurring meeting with fixed time only. Only applies if ApprovalType is not set to 'NoRegistartionRequired'.")]
        [string]$RegistrationType,
        [ValidateSet("Both", "Telephony", "VOIP")]
        [Parameter(Mandatory=$false, HelpMessage="Audio types allowed for this meeting. (Default: Both)")]
        [string]$AudioType,
        [ValidateSet("Local", "Cloud", "None")]
        [Parameter(Mandatory=$false, HelpMessage="Auto recording type (where the recording is stored). (Default: none)")]
        [string]$AutoRecording,
        [Parameter(Mandatory=$false, HelpMessage="Only allow registered users to join the meeting.")]
        [bool]$EnforceLogin,
        [Parameter(Mandatory=$false, HelpMessage="Only allow registered users with the given domain(s) to join the meeting.")]
        [string]$EnforceLoginDomains,
        [Parameter(Mandatory=$false, HelpMessage="List of alternative hosts (email-addresses, separated by ';').")]
        [string]$AlternativeHosts,
        [Parameter(Mandatory=$false, HelpMessage="Close registration after event date.")]
        [bool]$CloseRegistration,
        [Parameter(Mandatory=$false, HelpMessage="Enable waiting room.")]
        [bool]$EnableWaitingRoom,
        [Parameter(Mandatory=$false, HelpMessage="Name of the person responsible for registrations.")]
        [string]$RegistrationContactName,
        [Parameter(Mandatory=$false, HelpMessage="Email of the person responsible for registrations.")]
        [string]$RegistrationContactEmail
    )

    $endpoint = "users/{0}/meetings" -f $UserId

    $typeMap = @{
        "Instant" = 1
        "Scheduled" = 2
        "RecurringWithoutFixedtime" = 3
        "RecurringWithFixedtime" = 8
    }

    if (!$Password) {
        $sample = "abcdefghijklmnopqrstuvwxyz0123456789" # Full set of legal characters: "abcdefghijklmnopqrstuvwxyz0123456789@-_*"
        $Password = New-Object SecureString
        $rng = New-Object random

        for ($i=0; $i -lt 10; $i++) {
            $c = $sample[$rng.next($sample.length)]
            if ($rng.next(100) -lt 50) {
                $c = "$c".ToUpper()
            }
            $Password.appendChar($c)
        }
    }

    $headers = @{
        "Content-Type" = "application/json"
    }

    # Add basic info:
    $body = @{
        topic   =   $Title
        type    =   $typeMap[$Type]
        timezone = $TimeZone
        password = Unlock-SecureString $Password

        settings = @{}
        recurrence = @{}
    }

    if ($Description) {
        $body.agenda = $Description
    }

    if ($StartTime) {
        $body.start_time = "{0:yyy-MM-dd'T'HH:mm:ss}" -f $StartTime
    }

    if ($Duration) {
        $body.duration  = $Duration.TotalMinutes
    }

    # Add settings & Recurrence config:
    $map = @{

        # Recurrence Config:
        RecurrenceType      = {
            param($v) 
            $body.recurrence.type = switch ($v) {
                "Daily"   { 1 }
                "Weekly"  { 2 }
                "Monthly" { 3 }
            }
        }

        RecurrenceRepeatInterval    = { param($v) $body.recurrence."repeat_interval" = $v }
        
        RecurrenceWeekDays          = {
            param($v)
            $values = $v | Sort-Object -unique

            $r = @()

            foreach ($value in $values){
                switch -regex ($value.GetType().Name) {
                    "^Int\d{2}$"    { $r += $v }
                    "^String$"      {
                        $t = switch ($v) {
                            "sunday"    { 1 }
                            "monday"    { 2 }
                            "tuesday"   { 3 }
                            "wednesday" { 4 }
                            "thursday"  { 5 }
                            "friday"    { 6 }
                            "saturday"  { 7 }
                        }

                        if ($null -ne $t) {
                            $r += $t
                        }
                    }
                }
            }

            $body.recurrence."week_days" = $r -join ","
        }

        RecurrenceMonthlyDay = { param($v) $body.recurrence."monthly_day" }

        RecurrenceMonthlyWeek = {
            param($v)

            $body.recurrence."monthly_week" = switch ($v) {
                "Last"      { -1 }
                "First"     { 1 }
                "Second"    { 2 }
                "Third"     { 3 }
                "Fourth"    { 4 }
            }
        }

        RecurrenceMonthlyWeekDays = {
            param($v)

            $values = $v | Sort-Object -unique

            $r = @()

            foreach ($value in $values){
                switch -regex ($value.GetType().Name) {
                    "^Int\d{2}$"    { $r += $v }
                    "^String$"      {
                        $t = switch ($v) {
                            "sunday"    { 1 }
                            "monday"    { 2 }
                            "tuesday"   { 3 }
                            "wednesday" { 4 }
                            "thursday"  { 5 }
                            "friday"    { 6 }
                            "saturday"  { 7 }
                        }

                        if ($null -ne $t) {
                            $r += $t
                        }
                    }
                }
            }

            $body.recurrence."Monthly_week_day" = $r -join ","
        }

        RecurrenceMaxNumber = { param($v) $body.recurrence."end_times" = $v }

        RecurrenceEndDate = { param($v) $body.recurrence."end_date_time" = "{0:yyy-MM-dd'T'HH:mm:ss}" -f $v }

        # Settings:
        HostVideo           = { param($v) $body.settings."host_video" = $v }
        ParticipantVideo    = { param($v) $body.settings."participant_video" = $v }
        AllowJoinBeforeHost = { param($v) $body.settings."join_before_host" = $v }
        MuteOnJoin          = { param($v) $body.settings."mute_upn_entry" = $v }
        AddWatermark        = { param($v) $body.settings."watermark" = $v }

        ApprovalType        = {
            param($v)
            $body.settings."approval_type" = switch ($v) {
                "AutomaticallyApprove"   { 0 }
                "ManuallyApprove"        { 1 }
                "NoRegistrationRequired" { 2 }
            }
        }

        RegistrationType    = {
            param($v)
            $body.settings."registration_type" = switch ($v) {
                "OnceIncludeAll"    { 1 }
                "ForeachOccurence"  { 2 }
                "OnceSelective"     { 3 }
            }
        }

        AudioType           = {
            param($v)
            $body.settings.audio = switch ($v) {
                "Both" { "both" }
                "Telephony" { "telephony" }
                "VOIP" { "voip" }
            }
        }

        AutoRecording       = {
            param($v)
            $body.settings."auto_recording" = switch ($v) {
                "Local" { "local" }
                "Cloud" { "cloud" }
                "None"  { "none" }
            }
        }

        EnforceLogin        = { param($v) $body.settings."enforce_login" = $v }
        EnforceLoginDomains = { param($v) $body.settings."enforce_login_domains" = $v }
        AlternativeHosts    = { param($v) $body.settings."alternative_host" = $v }
        CloseRegistration   = { param($v) $body.settings."close_registration" = $v }
        EnableWaitingRoom   = { param($v) $body.settings."waiting_room" = $v }
        RegistrationContactName = { param($v) $body.settings."contact_name" = $v }
        RegistrationContactEmail = { param($v) $body.settings."contact_email" = $v }
    }

    $PSBoundParameters.Keys | Where-Object {
        $map.ContainsKey($_)
    } | ForEach-Object {
        . $map.$_ $PSBoundParameters[$_]
    }

    if ($body.recurrence.Count -eq 0) {
        $body.remove("recurrence")
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Post -Endpoint $endpoint -Body $jsonBody -Headers $headers
}