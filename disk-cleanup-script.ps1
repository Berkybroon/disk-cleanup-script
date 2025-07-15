# declare parameters, allowing the script to be run with switches such as -NonInteractive.
param(
	[switch]$NonInteractive
)

Write-Output "Disk Cleanup Script v2.0"

if ($NonInteractive) {
	Write-Output "Running in non-interactive mode..."
}

# windows temp - interactive prompt for confirmation when not using noninteractive switch.
if (!$NonInteractive) {
	$response = Read-Host "Clean windows temp files? (C:\Windows\Temp\*)"
	if ($response -eq "yes") {
		Write-Host "Cleaning..."
		Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
	}
} else {
	# do it anyway in non-interactive mode.
	Write-Host "Cleaning windows temp files (C:\Windows\Temp\*)"
	Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "Done!"
}

# appdata temp for every user folder - interactive prompt for confirmation when not using noninteractive switch.
if (!$NonInteractive) {
	$response = Read-Host "Clean each user's AppData temp files? (C:\Users\Example\AppData\Local\Temp\*)"
	if ($response -eq "yes") {
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
			Write-Host "Clearing folder $tempPath ..."
			Remove-Item "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
			Write-Host "Done!"
		}
	}
}

# windows update cleanup - interactive prompt for confirmation when not using noninteractive switch.
if (!$NonInteractive) {
	$response = Read-Host "Do windows update cleanup? (prefetch, softwaredistribution)"
	if ($response -eq "yes") {
		Write-Host "Cleaning prefetch folder..."
		Remove-Item "C:\Windows\prefetch\*.*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
		Write-Host "Cleaning SoftwareDistribution\Download folder..."
		Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
	}
} else {
	# do it anyway in non-interactive mode.
	Write-Host "Cleaning prefetch folder..."
	Remove-Item "C:\Windows\prefetch\*.*" -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "Done!"
	Write-Host "Cleaning SoftwareDistribution\Download folder..."
	Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
	Write-Host "Done!"
}

# recycle bins - interactive prompt for confirmation when not using noninteractive switch.
# this is skipped altogether in non-interactive mode to lessen chance of accidental deletion

if (!$NonInteractive) {
	$response = Read-Host "Clean recycle bins?"
	if ($response -eq "yes") {
		Write-Host "Cleaning recycle bins..."
		Remove-Item "C:\$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
		Write-Host "Done!"
	}
}
