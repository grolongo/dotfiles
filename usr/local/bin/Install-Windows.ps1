# Restriction: use "Set-ExecutionPolicy Bypass" as admin to allow this script to run

#Requires -RunAsAdministrator

function Request-Confirmation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$question
    )
    do {
        $response = Read-Host "$question [y/n]"
        $response = $response.ToLower()
        switch ($response) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Output "Please enter 'y' or 'n'"
            }
        }
    } while ($response -ne 'y' -and $response -ne 'n')
}

function Set-GPO {
    if (-not (Get-Module PolicyFileEditor -ListAvailable)) {
        Install-Module -Name PolicyFileEditor -Force
    }

    $machineDirectory = Join-Path $env:windir 'System32' 'GroupPolicy' 'Machine' 'Registry.pol'
    $registryPath01 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Personalization'
    $registryPath02 = Join-Path 'Software' 'Policies' 'Microsoft' 'InputPersonalization'
    $registryPath03 = Join-Path 'Software' 'Policies' 'Microsoft' 'MUI' 'Settings'
    $registryPath04 = Join-Path 'Software' 'Policies' 'Microsoft' 'Control Panel' 'International'
    $registryPath06 = Join-Path 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Policies' 'Explorer'
    $registryPath07 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'System'
    $registryPath08 = Join-Path 'Software' 'Policies' 'Microsoft' 'WindowsFirewall' 'DomainProfile'
    $registryPath09 = Join-Path 'Software' 'Policies' 'Microsoft' 'WindowsFirewall' 'StandardProfile'
    $registryPath10 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Explorer'
    $registryPath11 = Join-Path 'Software' 'Policies' 'Microsoft' 'SQMClient' 'Windows'
    $registryPath12 = Join-Path 'Software' 'Policies' 'Microsoft' 'PCHealth' 'ErrorReporting'
    $registryPath13 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Windows Error Reporting'
    $registryPath14 = Join-Path 'Software' 'Policies' 'Microsoft' 'Messenger' 'Client'
    $registryPath15 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows NT' 'SystemRestore'
    $registryPath16 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'AdvertisingInfo'
    $registryPath17 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'AppPrivacy'
    $registryPath18 = Join-Path 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Policies' 'System'
    $registryPath19 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'AppCompat'
    $registryPath20 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Windows Chat'
    $registryPath21 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'CloudContent'
    $registryPath22 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'PreviewBuilds'
    $registryPath23 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'DataCollection'
    $registryPath24 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'DWM'
    $registryPath25 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'EdgeUI'
    $registryPath26 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'LocationAndSensors'
    $registryPath27 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Maps'
    $registryPath28 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftAccount'
    $registryPath29 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows Defender'
    $registryPath30 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'ServiceUI'
    $registryPath31 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'Addons'
    $registryPath32 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'BooksLibrary'
    $registryPath33 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'Main'
    $registryPath34 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'TabPreloader'
    $registryPath35 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'Internet Settings'
    $registryPath36 = Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'SearchScopes'
    $registryPath38 = Join-Path 'Software' 'Microsoft' 'OneDrive'
    $registryPath39 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows OneDrive'
    $registryPath40 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows NT' 'Terminal Services'
    $registryPath41 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Windows Search'
    $registryPath42 = Join-Path 'Software' 'Policies' 'Microsoft' 'WindowsStore'
    $registryPath43 = Join-Path 'Software' 'Policies' 'Microsoft' 'Dsh'
    $registryPath44 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows GameDVR'
    $registryPath45 = Join-Path 'Software' 'Policies' 'Microsoft' 'PassportForWork'
    $registryPath46 = Join-Path 'Software' 'Policies' 'Microsoft' 'WindowsInkWorkspace'
    $registryPath47 = Join-Path 'Software' 'Policies' 'Microsoft' 'WindowsMediaPlayer'
    $registryPath48 = Join-Path 'Software' 'Policies' 'Microsoft' 'Messenger' 'Client'
    $registryPath49 = Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'WinRM' 'Service' 'WinRS'
    $registryPath50 = Join-Path 'Software' 'Policies' 'Microsoft' 'FVE'

    # Computer Configuration > Administrative Templates > Control Panel > Personalization
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath01 -ValueName 'AnimateLockScreenBackground'                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath01 -ValueName 'NoChangingStartMenuBackground'                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath01 -ValueName 'NoLockScreenCamera'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath01 -ValueName 'NoLockScreenSlideshow'                        -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > Regional and Language Options
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath02 -ValueName 'AllowInputPersonalization'                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath02 -ValueName 'PreferredUILanguages'                         -Data 'en-US' -Type 'String'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath03 -ValueName 'MachineUILock'                                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath04 -ValueName 'RestrictLanguagePacksAndFeaturesInstall'      -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > Regional and Language Options > Handwriting personalization
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath02 -ValueName 'RestrictImplicitTextCollection'               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath02 -ValueName 'RestrictImplicitInkCollection'                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > User Accounts
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'UseDefaultTile'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'AllowOnlineTips'                              -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Fonts
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath07 -ValueName 'EnableFontProviders'                          -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Domain Profile
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath08 -ValueName 'EnableFirewall'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Standard Profile
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath09 -ValueName 'EnableFirewall'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Start Menu and Taskbar
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'ForceStartSize'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'HideRecentlyAddedApps'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'HideRecommendedPersonalizedSites'             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'HideRecommendedSection'                       -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'ShowOrHideMostUsedApps'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoRecentDocsHistory'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'HideTaskViewButton'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'TaskbarNoPinnedList'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoStartMenuMFUprogramsList'                   -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > Internet Communication Management > Internet Communication settings
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath11 -ValueName 'CEIPEnable'                                   -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath12 -ValueName 'DoReport'                                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath13 -ValueName 'Disabled'                                     -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoInternetOpenWith'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'NoUseStoreOpenWith'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoWebServices'                                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoOnlinePrintsWizard'                         -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoPublishingWizard'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath14 -ValueName 'CEIP'                                         -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > Logon
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath07 -ValueName 'BlockUserFromShowingAccountDetailsOnSignin'   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath07 -ValueName 'DisableLockScreenAppNotifications'            -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > System Restore
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath15 -ValueName 'DisableSR'                                    -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath15 -ValueName 'DisableConfig'                                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > User Profiles
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath16 -ValueName 'DisabledByGroupPolicy'                        -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > App Privacy
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessAccountInfo'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessGazeInput'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessCallHistory'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessContacts'                        -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsGetDiagnosticInfo'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessEmail'                           -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessLocation'                        -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessMessaging'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessMotion'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessCamera'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessMicrophone'                      -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessBackgroundSpatialPerception'     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsActivateWithVoice'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsActivateWithVoiceAboveLock'            -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessRadios'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessPhone'                           -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsRunInBackground'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath17 -ValueName 'LetAppsAccessGraphicsCaptureProgrammatic'     -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > App runtime
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath18 -ValueName 'MSAOptional'                                  -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Application Compatibility
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath19 -ValueName 'AITEnable'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath19 -ValueName 'DisableInventory'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath19 -ValueName 'DisableUAR'                                   -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > AutoPlay Policies
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoDriveTypeAutoRun'                           -Data '255'   -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'NoAutoplayfornonVolume'                       -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath06 -ValueName 'NoAutorun'                                    -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > BitLocker Drive Encryption > Fixed drives
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'FDVEncryptionType'                            -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'FDVRecovery'                                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'FDVManageDRA'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'FDVActiveDirectoryBackup'                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'FDVAllowUserCert'                             -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > BitLocker Drive Encryption > OS drive
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'OSEncryptionType'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'UseAdvancedStartup'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'EnableBDEWithNoTPM'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'UseTPM'                                       -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'UseTPMKey'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'UseTPMKeyPIN'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'UseTPMPIN'                                    -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'UseEnhancedPin'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'OSRecovery'                                   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'OSManageDRA'                                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'OSRecoveryKey'                                -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'OSRecoveryPassword'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath50 -ValueName 'OSActiveDirectoryBackup'                      -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Chat
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath20 -ValueName 'ChatIcon'                                     -Data '3'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Cloud Content
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath21 -ValueName 'DisableSoftLanding'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath21 -ValueName 'DisableWindowsConsumerFeatures'               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath22 -ValueName 'AllowBuildPreview'                            -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath23 -ValueName 'AllowTelemetry'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath23 -ValueName 'DisableTelemetryOptInSettingsUx'              -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath23 -ValueName 'LimitDiagnosticLogCollection'                 -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath23 -ValueName 'LimitDumpCollection'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath23 -ValueName 'DoNotShowFeedbackNotifications'               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Desktop Window Manager
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath24 -ValueName 'DisableAccentGradient'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath24 -ValueName 'DisallowAnimations'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Edge UI
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath25 -ValueName 'AllowEdgeSwipe'                               -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath25 -ValueName 'DisableHelpSticker'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > File Explorer
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'ExplorerRibbonStartsMinimized'                -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath10 -ValueName 'DisableGraphRecentItems'                      -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Location and Sensors
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath26 -ValueName 'DisableLocation'                              -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath26 -ValueName 'DisableLocationScripting'                     -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Maps
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath27 -ValueName 'AutoDownloadAndUpdateMapData'                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath27 -ValueName 'AllowUntriggeredNetworkTrafficOnSettingsPage' -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft accounts
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath28 -ValueName 'DisableUserAuth'                              -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath29 -ValueName 'PUAProtection'                                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft Edge
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath30 -ValueName 'ShowOneBox'                                   -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath31 -ValueName 'FlashPlayerEnabled'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath32 -ValueName 'AllowConfigurationUpdateForBooksLibrary'      -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'AllowFullScreenMode'                          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'AllowPrelaunch'                               -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath34 -ValueName 'AllowTabPreloading'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath30 -ValueName 'AllowWebContentOnNewTabPage'                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'Use FormSuggest'                              -Data 'no'    -Type 'String'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'ConfigureFavoritesBar'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath35 -ValueName 'ConfigureHomeButton'                          -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'AllowPopups'                                  -Data 'yes'   -Type 'String'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath36 -ValueName 'ShowSearchSuggestionsGlobal'                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'SyncFavoritesBetweenIEAndMicrosoftEdge'       -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'PreventLiveTileDataCollection'                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath33 -ValueName 'PreventFirstRunPage'                          -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > OneDrive
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath38 -ValueName 'PreventNetworkTrafficPreUserSignIn'           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath39 -ValueName 'DisableFileSyncNGSC'                          -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath40 -ValueName 'fDenyTSConnections'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Search
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'AllowCloudSearch'                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'AllowCortanaAboveLock'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'AllowCortana'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'SearchOnTaskbarMode'                          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'DisableWebSearch'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'ConnectedSearchUseWeb'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'ConnectedSearchPrivacy'                       -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath41 -ValueName 'ConnectedSearchSafeSearch'                    -Data '3'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Store
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath42 -ValueName 'DisableOSUpgrade'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath42 -ValueName 'AutoDownload'                                 -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Widgets
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath43 -ValueName 'AllowNewsAndInterests'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath43 -ValueName 'DisableWidgetsOnLockScreen'                   -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Game Recording and Broadcasting
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath44 -ValueName 'AllowGameDVR'                                 -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Hello for Business
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath45 -ValueName 'Enabled'                                      -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Ink Workspace
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath46 -ValueName 'AllowWindowsInkWorkspace'                     -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Media Player
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath47 -ValueName 'QuickLaunchShortcut'                          -Data 'no'    -Type 'String'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Messenger
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath48 -ValueName 'PreventRun'                                   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath48 -ValueName 'PreventAutoRun'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Remote Shell
    Set-PolicyFileEntry -Path $machineDirectory -Key $registryPath49 -ValueName 'AllowRemoteShellAccess'                       -Data '0'     -Type 'DWord'

    # ===========
    # User Config
    # ===========

    $userDirectory = (Join-Path $env:windir 'System32' 'GroupPolicy' 'User' 'Registry.pol')
    $registryPath50 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Control Panel' 'Desktop')
    $registryPath51 = (Join-Path 'Software' 'Policies' 'Microsoft' 'InputPersonalization')
    $registryPath52 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Control Panel' 'Desktop')
    $registryPath53 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Control Panel' 'International')
    $registryPath54 = (Join-Path 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Policies' 'Explorer')
    $registryPath55 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Explorer')
    $registryPath56 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Assistance' 'Client' '1.0')
    $registryPath57 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Messenger' 'Client')
    $registryPath58 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'CloudContent')
    $registryPath59 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'DataCollection')
    $registryPath60 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'DWM')
    $registryPath61 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'EdgeUI')
    $registryPath62 = (Join-Path 'Software' 'Policies' 'Microsoft' 'ime' 'imejp')
    $registryPath63 = (Join-Path 'Software' 'Policies' 'Microsoft' 'ime' 'shared')
    $registryPath64 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'LocationAndSensors')
    $registryPath65 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'ServiceUI')
    $registryPath66 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'Addons')
    $registryPath67 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'BooksLibrary')
    $registryPath68 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'Main')
    $registryPath69 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'TabPreloader')
    $registryPath70 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'Internet Settings')
    $registryPath71 = (Join-Path 'Software' 'Policies' 'Microsoft' 'MicrosoftEdge' 'SearchScopes')
    $registryPath72 = (Join-Path 'Software' 'Policies' 'Microsoft' 'WindowsStore')
    $registryPath73 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'WindowsCopilot')
    $registryPath74 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Windows' 'Windows Error Reporting')
    $registryPath75 = (Join-Path 'Software' 'Policies' 'Microsoft' 'PassportForWork')
    $registryPath76 = (Join-Path 'Software' 'Policies' 'Microsoft' 'Messenger' 'Client')

    # User Configuration > Administrative Templates > Control Panel > Personalization
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath50 -ValueName 'ScreenSaveActive'                                               -Data '0'        -Type 'String'
    # User Configuration > Administrative Templates > Control Panel > Regional and Language Options
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath52 -ValueName 'PreferredUILanguages'                                           -Data 'en-US'    -Type 'String'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath52 -ValueName 'MultiUILanguageID'                                              -Data '00000409' -Type 'String'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath53 -ValueName 'RestrictLanguagePacksAndFeaturesInstall'                        -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath53 -ValueName 'TurnOffAutocorrectMisspelledWords'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath53 -ValueName 'TurnOffHighlightMisspelledWords'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath53 -ValueName 'TurnOffOfferTextPredictions'                                    -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Control Panel > Regional and Language Options > Handwriting personalization
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath51 -ValueName 'RestrictImplicitTextCollection'                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath51 -ValueName 'RestrictImplicitInkCollection'                                  -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Desktop
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoInternetIcon'                                                 -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Start Menu and Taskbar
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'ClearRecentDocsOnExit'                                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'ClearRecentProgForNewUserInStartMenu'                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoRecentDocsHistory'                                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'ForceStartSize'                                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'HideTaskViewButton'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'LockTaskbar'                                                    -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoTaskGrouping'                                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'HideRecentlyAddedApps'                                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoStartMenuMFUprogramsList'                                     -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'HideRecommendedPersonalizedSites'                               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'TaskbarNoPinnedList'                                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoStartMenuPinnedList'                                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoRecentDocsMenu'                                               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'HideRecommendedSection'                                         -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'HideSCAMeetNow'                                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'HidePeopleBar'                                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'ShowOrHideMostUsedApps'                                         -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'ShowWindowsStoreAppsOnTaskbar'                                  -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoAutoTrayNotify'                                               -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > System > Internet Communication Management > Internet Communication settings
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'NoUseStoreOpenWith'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath56 -ValueName 'NoImplicitFeedback'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoWebServices'                                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoInternetOpenWith'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoOnlinePrintsWizard'                                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoPublishingWizard'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath57 -ValueName 'CEIP'                                                           -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath56 -ValueName 'NoOnlineAssist'                                                 -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > AutoPlay Policies
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoAutorun'                                                      -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoDriveTypeAutoRun'                                             -Data '255'      -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'NoAutoplayfornonVolume'                                         -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Cloud Content
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'ConfigureWindowsSpotlight'                                      -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableThirdPartySuggestions'                                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableTailoredExperiencesWithDiagnosticData'                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableWindowsSpotlightFeatures'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableSpotlightCollectionOnDesktop'                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableWindowsSpotlightWindowsWelcomeExperience'                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableWindowsSpotlightOnActionCenter'                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath58 -ValueName 'DisableWindowsSpotlightOnSettings'                              -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath59 -ValueName 'AllowTelemetry'                                                 -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Desktop Window Manager
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath60 -ValueName 'DisallowAnimations'                                             -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Edge UI
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath61 -ValueName 'AllowEdgeSwipe'                                                 -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath61 -ValueName 'DisableHelpSticker'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath61 -ValueName 'DisableRecentApps'                                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath61 -ValueName 'DisableCharms'                                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath61 -ValueName 'TurnOffBackstack'                                               -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > File Explorer
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'MaxRecentDocs'                                                  -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'NoSearchInternetTryHarderButton'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'NoChangeAnimation'                                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'ExplorerRibbonStartsMinimized'                                  -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath54 -ValueName 'TurnOffSPIAnimations'                                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'DisableSearchBoxSuggestions'                                    -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > IME
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath62 -ValueName 'UseHistorybasedPredictiveInput'                                 -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath63 -ValueName 'SearchPlugin'                                                   -Data '0'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Location and Sensors
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath64 -ValueName 'DisableLocation'                                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath64 -ValueName 'DisableLocationScripting'                                       -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Microsoft Edge
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath65 -ValueName 'ShowOneBox'                                                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath66 -ValueName 'FlashPlayerEnabled'                                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath67 -ValueName 'AllowConfigurationUpdateForBooksLibrary'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'AllowFullScreenMode'                                            -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'AllowPrelaunch'                                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath69 -ValueName 'AllowTabPreloading'                                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath65 -ValueName 'AllowWebContentOnNewTabPage'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'Use FormSuggest'                                                -Data 'no'    -Type 'String'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'ConfigureFavoritesBar'                                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath70 -ValueName 'ConfigureHomeButton'                                            -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'AllowPopups'                                                    -Data 'yes'   -Type 'String'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath71 -ValueName 'ShowSearchSuggestionsGlobal'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'SyncFavoritesBetweenIEAndMicrosoftEdge'                         -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'PreventLiveTileDataCollection'                                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath68 -ValueName 'PreventFirstRunPage'                                            -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Search
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath55 -ValueName 'DisableSearchHistory'                                           -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Store
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath72 -ValueName 'DisableOSUpgrade'                                               -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Copilot
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath73 -ValueName 'TurnOffWindowsCopilot'                                          -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Error Reporting
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath74 -ValueName 'Disabled'                                                       -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Hello for Business
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath75 -ValueName 'Enabled'                                                        -Data '0'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Messenger
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath76 -ValueName 'PreventRun'                                                     -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDirectory -Key $registryPath76 -ValueName 'PreventAutoRun'                                                 -Data '1'     -Type 'DWord'

    Start-Sleep -Seconds 5
    gpupdate /force

    Write-Output 'Done.'
}

function Set-UIPreference {
    $explorer = Join-Path 'HKCU:' 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Explorer'
    $explorerAdvanced = Join-Path 'HKCU:' 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Explorer' 'Advanced'
    $personalize = Join-Path 'HKCU:' 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Themes' 'Personalize'

    # dark mode
    Write-Output 'Setting Windows dark mode...'
    Set-ItemProperty -Path $personalize -Name AppsUseLightTheme -Value 0
    Set-ItemProperty -Path $personalize -Name SystemUsesLightTheme -Value 0

    # hidden files
    Write-Output 'Show hidden files...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'Hidden' -Value 1

    # file extentions
    Write-Output 'Show file extentions...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'HideFileExt' -Value 0

    # Bing search
    Write-Output 'Disabling Bing search...'
    Set-ItemProperty -Path (Join-Path 'HKCU:' 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Search') -Name 'BingSearchEnabled' -Value 0

    # show icons notification area (always show = 0, not showing = 1)
    Write-Output 'Showing all tray icons...'
    Set-ItemProperty -Path $explorer -Name 'EnableAutoTray' -Value 0

    # taskbar alignment
    Write-Output 'Align taskbar to the left...'
    Set-ItemProperty -Path $explorerAdvanced -Name "TaskbarAl" -Value 0

    # taskbar size (small = 1, large = 0)
    Write-Output 'Setting taskbar height size to small...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'TaskbarSmallIcons' -Value 1

    # taskbar combine (always = 0, when full = 1, never = 2)
    Write-Output 'Setting taskbar combine when full mode...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'TaskbarGlomLevel' -Value 1

    # lock taskbar (lock = 0, unlock = 1)
    Write-Output 'Locking the taskbar...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'TaskbarSizeMove' -Value 0

    # disable recent files, folders and cloud files (hidden = 0, show = 1)
    Write-Output 'Disabling recent files and cloud folders...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'CloudFilesOnDemand' -Value 0
    Set-ItemProperty -Path $explorerAdvanced -Name 'Start_TrackDocs' -Value 0
    Set-ItemProperty -Path $explorer -Name 'ShowFrequent' -Value 0

    # Start menu layout
    Write-Output 'Setting up the Start menu...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'Start_Layout' -Value 1 # (1 = More pins, 2 = More recommendations, 3 = Default)

    # disable transparency (1 = enabled, 0 = disabled)
    Write-Output 'Disabling transparency effects...'
    Set-ItemProperty -Path $personalize -Name 'EnableTransparency' -Value 0

    # sticky keys
    Write-Output 'Disabling sticky keys...'
    Set-ItemProperty -Path (Join-Path 'HKCU:' 'Control Panel' 'Accessibility' 'StickyKeys') -Name Flags -Value 58

    # snap windows
    Write-Output 'Disabling snapping of windows on startup...'
    Set-ItemProperty -Path (Join-Path 'HKCU:' 'Control Panel' 'Desktop') -Name WindowArrangementActive -Value 0
    Write-Output 'Disabling snap assist suggestion on startup...'
    Set-ItemProperty -Path $explorerAdvanced -Name WindowArrangementActive -Value 0
    Write-Output 'Disabling snap assist flyout on startup...'
    Set-ItemProperty -Path $explorerAdvanced -Name EnableSnapAssistFlyout -Value 0

    # recall
    Write-Output "Disabling Recall..."
    Set-ItemProperty -Path (Join-Path 'HKLM:' 'Software' 'Policies' 'Microsoft' 'Windows' 'WindowsAI') -Name 'DisableAIDataAnalysis' -Value 1
    DISM /Online /Disable-Feature /FeatureName:Recall

    # screenshot folder
    Write-Output 'Setting the screenshot folder to Desktop...'
    Set-ItemProperty -Path (Join-Path 'HKCU:' 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Explorer' 'User Shell Folders') -Name '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}' -Value (Join-Path $env:USERPROFILE 'Desktop')

    # region
    if (Request-Confirmation 'Set timezone/currency/timeformat to fr-FR?') {
        Set-TimeZone -Name 'Romance Standard Time'
        Set-Culture fr-FR
    }

    # openssh
    Write-Output 'Enabling OpenSSH at startup...'
    Set-Service ssh-agent -StartupType Automatic

    # no sound settings
    Write-Output 'Switching Sound Scheme to no sounds...'
    New-ItemProperty -Path (Join-Path 'HKCU:' 'AppEvents' 'Schemes') -Name '(Default)' -Value '.None' -Force | Out-Null
    Get-ChildItem -Path (Join-Path 'HKCU:' 'AppEvents' 'Schemes' 'Apps') -Recurse | Where-Object { $_.PSChildName -eq '.Current' } | Set-ItemProperty -Name '(Default)' -Value ''

    Write-Output 'Turning Windows Startup sound off...'
    Set-ItemProperty -Path (Join-Path 'HKLM:' 'Software' 'Microsoft' 'Windows' 'CurrentVersion' 'Policies' 'System') -Name 'DisableStartupSound' -Value 1 -Type DWord -Force

    # keyboard settings
    $languageList = Get-WinUserLanguageList

    if (-not $languageList | Where-Object { $_.InputMethodTips -contains "0409:0000040C" }) {
        if (Request-Confirmation 'FR keyboard layout not detected, install?') {
            $languageList[0].InputMethodTips.Add('0409:0000040C')
            Set-WinUserLanguageList $languageList -Force
            Set-WinDefaultInputMethodOverride -InputTip "0409:0000040C"
        }
    }

    if (Request-Confirmation 'Remap ctrl to capslock key?') {
        $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | ForEach-Object { "0x$_"}
        $keyboardLayout = Join-Path 'HKLM:' 'System' 'CurrentControlSet' 'Control' 'Keyboard Layout'
        New-ItemProperty -Path $keyboardLayout -Name 'Scancode Map' -PropertyType Binary -Value ([byte[]]$hexified)
    }

    # mouse settings
    Write-Output 'Disabling mouse acceleration...'
    $mousePath = Join-Path 'HKCU:' 'Control Panel' 'Mouse'
    Set-ItemProperty -Path $mousePath -Name MouseSpeed -Value 0
    Set-ItemProperty -Path $mousePath -Name MouseThreshold1 -Value 0
    Set-ItemProperty -Path $mousePath -Name MouseThreshold2 -Value 0

    Stop-Process -Name explorer -Force
    Write-Output 'You should relog for changes to take effect. Done.'
}

function Set-BitLocker {
    if (Request-Confirmation 'Encrypt C: drive?') {
        manage-bde -protectors -add c: -TPMAndPIN
        Start-Sleep -Seconds 3
        manage-bde -on c: -RecoveryPassword
    }

    $drives = (Get-BitlockerVolume | Where-Object {$_.AutoUnlockEnabled -eq $false}).MountPoint

    if ($drives) {
        foreach ($drive in $drives) {
            if (Request-Confirmation "Automatically unlock $drive at boot?") {
                manage-bde -unlock "$drive" -password
                Start-Sleep -Seconds 10
                manage-bde -autounlock -enable "$drive"
            }
        }
    }

    Write-Output 'Done.'
}

function Set-FireWall {
    if (Request-Confirmation 'Block incoming connections and allow outgoing?') {
        Set-NetConnectionProfile -NetworkCategory Private
        netsh advfirewall set allprofiles state on
        netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set publicprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set privateprofile firewallpolicy blockinboundalways,allowoutbound
        Write-Output 'Done.'
    } else {
        Write-Output 'Aborted.'
    }
}

function Set-PowerSetting {
    Write-Output 'Turning off all power saving mode when on AC power...'
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0

    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem

    if ($computerSystem.PCSystemType -eq 2) {
        Write-Output 'Running on a laptop, keeping hibernate on...'
    } else {
        Write-Output 'Turning hibernate off...'
        powercfg.exe /HIBERNATE off
    }

    Write-Output 'Done.'
}

function Install-WinGet {

    $packages = @(
        '7zip.7zip',
        'aria2.aria2',
        'AutoHotkey.AutoHotkey',
        'Chatty.Chatty',
        'Synology.DriveClient',
        'Electrum.Electrum',
        'voidtools.Everything',
        'OliverBetz.ExifTool',
        'sharkdp.fd',
        'FeatherWallet.Feather',
        'Gyan.FFmpeg',
        'Mozilla.Firefox',
        'XavierRoche.HTTrack',
        'GnuPG.GnuPG',
        'ImageMagick.ImageMagick',
        'DominikReichl.KeePass',
        'GnuWin32.Make',
        'Microsoft.MouseandKeyboardCenter',
        'MullvadVPN.MullvadVPN',
        'Insecure.Nmap',
        'nomacs.nomacs',
        'OBSProject.OBSStudio',
        'Microsoft.PowerShell',
        'Microsoft.PowerToys',
        'Python.Python.3.12',
        'BurntSushi.ripgrep.MSVC',
        'koalaman.shellcheck',
        'OpenWhisperSystems.Signal',
        'Henry++.simplewall',
        'AntoineAflalo.SoundSwitch',
        'Spotify.Spotify',
        'Streamlink.Streamlink',
        'Valve.Steam',
        'Telegram.TelegramDesktop',
        'IDRIX.VeraCrypt',
        'Oracle.VirtualBox',
        'Microsoft.VisualStudioCode',
        'Microsoft.WindowsTerminal',
        'yt-dlp.yt-dlp'
    )

    if (Request-Confirmation 'Install WinGet from GitHub (instead of Microsoft Store)?') {
        $apiUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
        $wingetDownloadUrl = $(Invoke-RestMethod $apiUrl).assets.browser_download_url | Where-Object {$_.EndsWith('.msixbundle')}
        $wingetDownloadLocation = Join-Path $env:TEMP 'winget.msixbundle'

        Invoke-WebRequest -Uri $wingetDownloadUrl -OutFile $wingetDownloadLocation
        Add-AppxPackage -Path $wingetDownloadLocation
        Remove-Item $wingetDownloadLocation
    }

    winget source update

    foreach ($p in $packages) {
        if (Request-Confirmation "Install ${p}?") { winget install -e --id "$p" }
    }

    if (Request-Confirmation 'Install Emacs?') {
        winget install -e --id 'GNU.Emacs'
        $emacsInstallDirectory = Join-Path $env:ProgramFiles 'Emacs'
        $emacsConfigDirectory = Join-Path $env:APPDATA '.emacs.d'
        Add-MpPreference -ExclusionPath $emacsInstallDirectory, $emacsConfigDirectory
        Add-MpPreference -ExclusionProcess (Join-Path $emacsInstallDirectory "*"), 'runemacs.exe', 'emacs.exe', 'emacsclientw.exe', 'emacsclient.exe'
        Add-MpPreference -ExclusionExtension ".el", ".elc", ".eln"

        winget install -e --id 'FSFhu.Hunspell'
        $hunspellDirectory = Join-Path $env:APPDATA '.emacs.d' 'hunspell'
        New-Item -Force -Path $hunspellDirectory -ItemType directory
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff' -OutFile (Join-Path $hunspellDirectory 'en_US.aff')
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff' -OutFile (Join-Path $hunspellDirectory 'en_US.dic')
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff' -OutFile (Join-Path $hunspellDirectory 'fr_FR.aff')
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff' -OutFile (Join-Path $hunspellDirectory 'fr_FR.dic')
    }

    if (Request-Confirmation 'Install Git?') {
        winget install -e --id Git.Git --custom '/o:EditorOption=Notepad /o:Components=icons,gitlfs,windowsterminal /o:PathOption=Cmd /o:SSHOption=ExternalOpenSSH /o:CRLFOption=CRLFCommitAsIs /o:CURLOption=WinSSL'
    }

    if (Request-Confirmation 'Install MKVToolNix?') {
        winget install -e --id 'MoritzBunkus.MKVToolNix'
        $mkvtoolnixInstallDirectory = Join-Path $env:ProgramFiles 'MKVToolNixx'
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$mkvtoolnixInstallDirectory", [EnvironmentVariableTarget]::User)
    }

    if (Request-Confirmation 'Install qBittorrent?') {
        winget install -e --id 'qBittorrent.qBittorrent'
        $pluginDirectory = Join-Path $env:USERPROFILE 'AppData' 'Local' 'qBittorrent' 'nova3' 'engines'
        New-Item -Force -Path $pluginDirectory -ItemType directory

        $pluginUrl = @(
            # Official plugins
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/eztv.py',
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/limetorrents.py',
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/piratebay.py',
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/solidtorrents.py',
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torlock.py',
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentproject.py',
            'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentscsv.py',

            # Third Party
            'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/bitsearch.py',
            'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/therarbg.py',
            'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/torrentdownloads.py',
            'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py',
            'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py',
            'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py',
            'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/snowfl.py',
            'https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/dodi_repacks.py',
            'https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/fitgirl_repacks.py',
            'https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py',
            'https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/master/engines/nyaasi.py',
            'https://scare.ca/dl/qBittorrent/torrentdownload.py',
            'https://scare.ca/dl/qBittorrent/magnetdl.py',
            'https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py',
            'https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py',
            'https://gist.githubusercontent.com/scadams/56635407b8dfb8f5f7ede6873922ac8b/raw/f654c10468a0b9945bec9bf31e216993c9b7a961/one337x.py',
            'https://raw.githubusercontent.com/AlaaBrahim/qBitTorrent-animetosho-search-plugin/main/animetosho.py',
            'https://raw.githubusercontent.com/TuckerWarlock/qbittorrent-search-plugins/main/bt4gprx.com/bt4gprx.py',
            'https://raw.githubusercontent.com/MarcBresson/cpasbien/master/src/cpasbien.py',
            'https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py',
            'https://raw.githubusercontent.com/menegop/qbfrench/master/torrent9.py',
            'https://raw.githubusercontent.com/amongst-us/qbit-plugins/main/yts_mx/yts_mx.py',
            'https://raw.githubusercontent.com/444995/qbit-search-plugins/main/engines/zooqle.py',
            'https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py'
        )

        # Loop through each URL and download the file
        foreach ($url in $pluginUrl) {
            $plugineFilename = [System.IO.Path]::GetFileName($url)
            $pluginFileLocation = Join-Path $pluginDirectory $plugineFilename
            Invoke-WebRequest -Uri $url -OutFile $pluginFileLocation
        }
    }

    if (Request-Confirmation 'Install Tor Browser?') {
        winget install -e --id 'TorProject.TorBrowser'
        Start-Sleep -Seconds 5
        Move-Item -Path (Join-Path $env:USERPROFILE 'Desktop' 'Tor Browser') -Destination $env:ProgramFiles

        $torProgramLocation = Join-Path $env:ProgramFiles 'Tor Browser' 'Browser' 'firefox.exe'
        $torShortcutLocation = Join-Path $env:APPDATA 'Microsoft' 'Windows' 'Start Menu' 'Programs' 'Tor Browser.lnk'

        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($torShortcutLocation)
        $shortcut.TargetPath = $torProgramLocation
        $shortcut.Save()
    }

    if (Request-Confirmation 'Install iCloud?') {
        winget install --source msstore 9PKTQ5699M62
    }

    Write-Output 'Done.'
}

function Install-MPV {
    Write-Output 'Installing latest mpv...'

    $apiUrl = "https://api.github.com/repos/shinchiro/mpv-winbuild-cmake/releases/latest"
    $mpvDownloadUrl = $(Invoke-RestMethod $apiUrl).assets.browser_download_url | Where-Object { $_.Contains('mpv-x86_64-v3')}
    $mpvDownloadLocation = Join-Path $env:TEMP 'mpv.7z'
    $mpvInstallDirectory = Join-Path $env:ProgramFiles 'mpv'

    Invoke-WebRequest -Uri $mpvDownloadUrl -OutFile $mpvDownloadLocation
    Install-Module -Name 7Zip4Powershell
    Expand-7zip -ArchiveFileName $mpvDownloadLocation -TargetPath $mpvInstallDirectory
    Remove-Item $mpvDownloadLocation
    [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$mpvInstallDirectory", [EnvironmentVariableTarget]::User)

    Write-Output 'Running mpv script(s)...'
    Start-Process -FilePath (Join-Path $mpvInstallDirectory 'installer' 'mpv-install.bat') -NoNewWindow -Wait

    Write-Output 'Installing plugins...'

    $mpvConfigDirectory = Join-Path $env:APPDATA 'mpv'
    $mpvScriptDirectory = Join-Path $mpvConfigDirectory 'scripts'
    $uoscDirectory = Join-Path $env:TEMP 'uosc.zip'

    New-Item -Force -Path $mpvConfigDirectory -ItemType directory
    New-Item -Force -Path (Join-Path $mpvConfigDirectory 'fonts') -ItemType directory
    New-Item -Force -Path $mpvScriptDirectory -ItemType directory
    New-Item -Force -Path (Join-Path $mpvScriptDirectory 'uosc') -ItemType directory

    Invoke-WebRequest -Uri 'https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip' -OutFile $uoscDirectory
    Expand-Archive -Path $uoscDirectory -DestinationPath $mpvConfigDirectory
    Remove-Item $uoscDirectory

    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua' -OutFile (Join-Path $mpvScriptDirectory 'thumbfast.lua')
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/mfcc64/mpv-scripts/master/visualizer.lua' -OutFile (Join-Path $mpvScriptDirectory 'visualizer.lua')
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/crop.lua' -OutFile (Join-Path $mpvScriptDirectory 'crop.lua')
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/encode.lua' -OutFile (Join-Path $mpvScriptDirectory 'encode.lua')

    Write-Output 'Done.'
}

function Install-Findutils {
    Write-Output 'Installing Findutils...'

    $findutilsDownloadLocation = Join-Path $env:TEMP 'findutils.pkg.tar.zst'
    $findutilsInstallDirectory = Join-Path $env:ProgramFiles 'GnuFindutils'
    $findutilsBinariesDirectory = Join-Path $findutilsInstallDirectory 'usr' 'bin'

    New-Item -Force -Path $findutilsInstallDirectory -ItemType directory
    Invoke-WebRequest -Uri 'https://mirror.msys2.org/msys/x86_64/findutils-4.10.0-2-x86_64.pkg.tar.zst' -OutFile $findutilsDownloadLocation
    tar --extract --file=$findutilsDownloadLocation --directory=$findutilsInstallDirectory
    Remove-Item $findutilsDownloadLocation
    [Environment]::SetEnvironmentVariable("Path", "$findutilsBinariesDirectory;" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine), [EnvironmentVariableTarget]::Machine)

    Write-Output 'Done.'
}

function Use-Massgrave {
    Invoke-RestMethod 'https://get.activated.win' | Invoke-Expression
}

function Set-Git {
    Write-Output 'Setting up origin for the git repository...'

    Push-Location
    Set-Location (Join-Path $env:USERPROFILE "dotfiles")

    if (git rev-parse --is-inside-work-tree) {
        git remote set-url origin git@github.com:grolongo/dotfiles.git
    } else {
        git init
        git remote add origin git@github.com:grolongo/dotfiles.git
        git fetch
        git reset origin/master
        git branch --set-upstream-to=origin/master
    }

    Pop-Location

    Write-Output 'Done.'
}

function usage {
    Write-Output ''
    Write-Output 'Usage:'
    Write-Output '  gpo             - apply machine and user group policies'
    Write-Output '  uisetting       - explorer, taskbar, keyboard and other preferences'
    Write-Output '  bitlocker       - change Group Policy settings for BitLocker and encrypts C:'
    Write-Output '  firewall        - firewall rules: block incoming, allow outgoing'
    Write-Output '  powersetting    - disable power saving modes on AC power'
    Write-Output '  winget          - download and install some packages with winget'
    Write-Output '  mpv             - install mpv'
    Write-Output '  findutils       - install GNU Findutils'
    Write-Output '  activate        - run massgrave activation script'
    Write-Output '  git             - set correct SSH origin for this repository'
    Write-Output ''
}

function main {
    $cmd = $args[0]

    # return error if nothing is specified
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq 'gpo')                 { Set-GPO }
    elseif ($cmd -eq 'uisetting')       { Set-UIPreference }
    elseif ($cmd -eq 'bitlocker')       { Set-BitLocker }
    elseif ($cmd -eq 'firewall')        { Set-FireWall }
    elseif ($cmd -eq 'powersetting')    { Set-PowerSetting }
    elseif ($cmd -eq 'winget')          { Install-WinGet }
    elseif ($cmd -eq 'mpv')             { Install-MPV }
    elseif ($cmd -eq 'findutils')       { Install-Findutils }
    elseif ($cmd -eq 'activate')        { Use-Massgrave }
    elseif ($cmd -eq 'git')             { Set-Git }
    else { usage }
}

main $args[0]
