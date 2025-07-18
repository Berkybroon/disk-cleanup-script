# declare parameters, allowing the script to be run with switches such as -NonInteractive.
param(
	[switch]$NonInteractive
)

Write-Host "Disk Cleanup Script v2.0" -ForegroundColor Red

if ($NonInteractive) {
	Write-Output "Running in non-interactive mode."
}

if (!$NonInteractive) {
	Write-Host "Running in interactive mode."
	Write-Host "When prompted for confirmation on each operation, please enter Y for yes."
	Write-Host "Any other input will skip the operation and proceed to the next."
}

# windows temp - interactive prompt for confirmation when not using noninteractive switch.
if (!$NonInteractive) {
	$response = Read-Host "Clean windows temp files? (C:\Windows\Temp\*)"
	if ($response -eq "Y") {
		Write-Host "Cleaning..."
		Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
	}
} else {
	# do it anyway in non-interactive mode.
	Write-Output "Cleaning windows temp files (C:\Windows\Temp\*)"
	Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
	Write-Output "Done!"
}

# appdata temp for every user folder - interactive prompt for confirmation when not using noninteractive switch.
if (!$NonInteractive) {
	$response = Read-Host "Clean each user's AppData temp files? (C:\Users\Example\AppData\Local\Temp\*)"
	if ($response -eq "Y") {
		Write-Host "Starting..."
		Get-ChildItem 'C:\Users' -Directory | ForEach-Object {
			$tempPath = Join-Path $_.FullName 'AppData\Local\Temp'
			if (Test-Path $tempPath) {
				Write-Host "Clearing folder $tempPath ..."
				Remove-Item "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
				Write-Host "Done!"
			}
		}
		Write-Host "All users done, continuing..."
	}
} else {
	# do it anyway in non-interactive mode.
	Get-ChildItem 'C:\Users' -Directory | ForEach-Object {
		$tempPath = Join-Path $_.FullName 'AppData\Local\Temp'
		if (Test-Path $tempPath) {
			Write-Output "Clearing folder $tempPath ..."
			Remove-Item "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
			Write-Output "Done!"
		}
	}
	Write-Output "All users done, continuing..."
}

# windows update cleanup - interactive prompt for confirmation when not using noninteractive switch.
if (!$NonInteractive) {
	$response = Read-Host "Do windows update cleanup? (prefetch, softwaredistribution)"
	if ($response -eq "Y") {
		Write-Host "Cleaning prefetch folder..."
		Remove-Item "C:\Windows\prefetch\*.*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
		Write-Host "Cleaning SoftwareDistribution\Download folder..."
		Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
	}
} else {
	# do it anyway in non-interactive mode.
	Write-Output "Cleaning prefetch folder..."
	Remove-Item "C:\Windows\prefetch\*.*" -Recurse -Force -ErrorAction SilentlyContinue
	Write-Output "Done!"
	Write-Output "Cleaning SoftwareDistribution\Download folder..."
	Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
	Write-Output "Done!"
}

# recycle bins - interactive prompt for confirmation when not using noninteractive switch.
# skipped altogether in non-interactive mode to prevent accidental deletion

if (!$NonInteractive) {
	$response = Read-Host "Clean recycle bins?"
	if ($response -eq "Y") {
		Write-Host "Cleaning recycle bins..."
		Remove-Item "C:\$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
	}
}

# dormant roaming profiles- interactive prompt for confirmation when not using non-interactive switch.
# skipped altogether in non-interactive mode to prevent accidental deletion

if (!$NonInteractive) {
	$response = Read-Host "Remove dormant roaming profiles?"
	if ($response -eq "Y") {
		# prompt for threshold (in years)
		do {
			$years = 0
			Write-Host "Please enter a number of years (e.g. 2) as the inactivity threshold. Must be greater than 1."
			$yearsInput = Read-Host "User folders that have not been accessed for x years will be removed."
			$valid = [int]::TryParse($yearsInput, [ref]$years) -and ($years -gt 1)
			if (-not $valid) {
				Write-Host "Invalid input. Please read the instruction prompt." -ForegroundColor Red
			}
		} until ($valid)
		
		$threshold = (Get-Date).AddYears(-$years)
	
		# get stale profile folders by LastAccessTime
		$staleFolders = Get-ChildItem 'C:\Users' -Directory |
			Where-Object {
				$_.Name -notin @('Public', 'Default', 'Default User', 'All Users', 'Administrator', 'DefaultAppPool') -and
				$_.LastWriteTime -lt $threshold
			}
		
		# convert to full paths and make an array of associated profiles
		$staleFolderPaths = $staleFolders.FullName	
		$targetProfiles = Get-CimInstance Win32_UserProfile | Where-Object {
			$_.LocalPath -in $staleFolderPaths
		}
	
		# final confirmation before deleting
		if ($targetProfiles) {
			Write-Host "The following profiles have not been accessed within the given time frame ($threshold):"
			$targetProfiles | Select-Object LocalPath, @{Name='LastUse';Expression={[datetime]::FromFileTime($_.LastUseTime)}} | Format-Table -AutoSize
		
			$response = Read-Host "Proceed with removal?"
			if ($response -eq "Y") {	
				$targetProfiles | ForEach-Object {
					Write-Host "Deleting: $($_.LocalPath)"
					$_ | Remove-CimInstance -Confirm:$false
				}
				Write-Host "Done!"
			} else {
				Write-Host "Operation aborted."
			}
		} else {
			Write-Host "No stale profiles older than $years years discovered."
		}
	}
}

Write-Output "All operations completed. Exiting..."
