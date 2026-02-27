# Restriction: use "Set-ExecutionPolicy Bypass" as admin to allow this script to run

#Requires -RunAsAdministrator

$tempFolder = [System.Environment]::GetEnvironmentVariable('TEMP','User')

function Ask-Question {
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
                Write-Host "Please enter 'y' or 'n'"
            }
        }
    } while ($response -ne 'y' -and $response -ne 'n')
}

function Write-Message {
    param(
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    Write-Host -ForegroundColor 'yellow' $message
}

function Apply-GPO {

    if (-not (Get-Module PolicyFileEditor -ListAvailable)) {
        Install-Module -Name PolicyFileEditor -Force
    }

    $machineDir = "$env:windir\System32\GroupPolicy\Machine\Registry.pol"

    $regPath01 = 'Software\Policies\Microsoft\Windows\Personalization'
    $regPath02 = 'Software\Policies\Microsoft\InputPersonalization'
    $regPath03 = 'Software\Policies\Microsoft\MUI\Settings'
    $regPath04 = 'Software\Policies\Microsoft\Control Panel\International'
    $regPath06 = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $regPath07 = 'Software\Policies\Microsoft\Windows\System'
    $regPath08 = 'Software\Policies\Microsoft\WindowsFirewall\DomainProfile'
    $regPath09 = 'Software\Policies\Microsoft\WindowsFirewall\StandardProfile'
    $regPath10 = 'Software\Policies\Microsoft\Windows\Explorer'
    $regPath11 = 'Software\Policies\Microsoft\SQMClient\Windows'
    $regPath12 = 'Software\Policies\Microsoft\PCHealth\ErrorReporting'
    $regPath13 = 'Software\Policies\Microsoft\Windows\Windows Error Reporting'
    $regPath14 = 'Software\Policies\Microsoft\Messenger\Client'
    $regPath15 = 'Software\Policies\Microsoft\Windows NT\SystemRestore'
    $regPath16 = 'Software\Policies\Microsoft\Windows\AdvertisingInfo'
    $regPath17 = 'Software\Policies\Microsoft\Windows\AppPrivacy'
    $regPath18 = 'Software\Microsoft\Windows\CurrentVersion\Policies\System'
    $regPath19 = 'Software\Policies\Microsoft\Windows\AppCompat'
    $regPath20 = 'Software\Policies\Microsoft\Windows\Windows Chat'
    $regPath21 = 'Software\Policies\Microsoft\Windows\CloudContent'
    $regPath22 = 'Software\Policies\Microsoft\Windows\PreviewBuilds'
    $regPath23 = 'Software\Policies\Microsoft\Windows\DataCollection'
    $regPath24 = 'Software\Policies\Microsoft\Windows\DWM'
    $regPath25 = 'Software\Policies\Microsoft\Windows\EdgeUI'
    $regPath26 = 'Software\Policies\Microsoft\Windows\LocationAndSensors'
    $regPath27 = 'Software\Policies\Microsoft\Windows\Maps'
    $regPath28 = 'Software\Policies\Microsoft\MicrosoftAccount'
    $regPath29 = 'Software\Policies\Microsoft\Windows Defender'
    $regPath30 = 'Software\Policies\Microsoft\MicrosoftEdge\ServiceUI'
    $regPath31 = 'Software\Policies\Microsoft\MicrosoftEdge\Addons'
    $regPath32 = 'Software\Policies\Microsoft\MicrosoftEdge\BooksLibrary'
    $regPath33 = 'Software\Policies\Microsoft\MicrosoftEdge\Main'
    $regPath34 = 'Software\Policies\Microsoft\MicrosoftEdge\TabPreloader'
    $regPath35 = 'Software\Policies\Microsoft\MicrosoftEdge\Internet Settings'
    $regPath36 = 'Software\Policies\Microsoft\MicrosoftEdge\SearchScopes'
    $regPath38 = 'Software\Microsoft\OneDrive'
    $regPath39 = 'Software\Policies\Microsoft\Windows\OneDrive'
    $regPath40 = 'Software\Policies\Microsoft\Windows NT\Terminal Services'
    $regPath41 = 'Software\Policies\Microsoft\Windows\Windows Search'
    $regPath42 = 'Software\Policies\Microsoft\WindowsStore'
    $regPath43 = 'Software\Policies\Microsoft\Dsh'
    $regPath44 = 'Software\Policies\Microsoft\Windows\GameDVR'
    $regPath45 = 'Software\Policies\Microsoft\PassportForWork'
    $regPath46 = 'Software\Policies\Microsoft\WindowsInkWorkspace'
    $regPath47 = 'Software\Policies\Microsoft\WindowsMediaPlayer'
    $regPath48 = 'Software\Policies\Microsoft\Messenger\Client'
    $regPath49 = 'Software\Policies\Microsoft\Windows\WinRM\Service\WinRS'
    $regPath50 = 'Software\Policies\Microsoft\FVE'

    # Computer Configuration > Administrative Templates > Control Panel > Personalization
    Set-PolicyFileEntry -Path $machineDir -Key $regPath01 -ValueName 'AnimateLockScreenBackground'                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath01 -ValueName 'NoChangingStartMenuBackground'                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath01 -ValueName 'NoLockScreenCamera'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath01 -ValueName 'NoLockScreenSlideshow'                        -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > Regional and Language Options
    Set-PolicyFileEntry -Path $machineDir -Key $regPath02 -ValueName 'AllowInputPersonalization'                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath02 -ValueName 'PreferredUILanguages'                         -Data 'en-US' -Type 'String'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath03 -ValueName 'MachineUILock'                                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath04 -ValueName 'RestrictLanguagePacksAndFeaturesInstall'      -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > Regional and Language Options > Handwriting personalization
    Set-PolicyFileEntry -Path $machineDir -Key $regPath02 -ValueName 'RestrictImplicitTextCollection'               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath02 -ValueName 'RestrictImplicitInkCollection'                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > User Accounts
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'UseDefaultTile'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'AllowOnlineTips'                              -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Fonts
    Set-PolicyFileEntry -Path $machineDir -Key $regPath07 -ValueName 'EnableFontProviders'                          -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Domain Profile
    Set-PolicyFileEntry -Path $machineDir -Key $regPath08 -ValueName 'EnableFirewall'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Standard Profile
    Set-PolicyFileEntry -Path $machineDir -Key $regPath09 -ValueName 'EnableFirewall'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Start Menu and Taskbar
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'ForceStartSize'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'HideRecentlyAddedApps'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'HideRecommendedPersonalizedSites'             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'HideRecommendedSection'                       -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'ShowOrHideMostUsedApps'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoRecentDocsHistory'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'HideTaskViewButton'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'TaskbarNoPinnedList'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoStartMenuMFUprogramsList'                   -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > Internet Communication Management > Internet Communication settings
    Set-PolicyFileEntry -Path $machineDir -Key $regPath11 -ValueName 'CEIPEnable'                                   -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath12 -ValueName 'DoReport'                                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath13 -ValueName 'Disabled'                                     -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoInternetOpenWith'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'NoUseStoreOpenWith'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoWebServices'                                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoOnlinePrintsWizard'                         -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoPublishingWizard'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath14 -ValueName 'CEIP'                                         -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > Logon
    Set-PolicyFileEntry -Path $machineDir -Key $regPath07 -ValueName 'BlockUserFromShowingAccountDetailsOnSignin'   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath07 -ValueName 'DisableLockScreenAppNotifications'            -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > System Restore
    Set-PolicyFileEntry -Path $machineDir -Key $regPath15 -ValueName 'DisableSR'                                    -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath15 -ValueName 'DisableConfig'                                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > User Profiles
    Set-PolicyFileEntry -Path $machineDir -Key $regPath16 -ValueName 'DisabledByGroupPolicy'                        -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > App Privacy
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessAccountInfo'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessGazeInput'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessCallHistory'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessContacts'                        -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsGetDiagnosticInfo'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessEmail'                           -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessLocation'                        -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessMessaging'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessMotion'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessCamera'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessMicrophone'                      -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessBackgroundSpatialPerception'     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsActivateWithVoice'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsActivateWithVoiceAboveLock'            -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessRadios'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessPhone'                           -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsRunInBackground'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath17 -ValueName 'LetAppsAccessGraphicsCaptureProgrammatic'     -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > App runtime
    Set-PolicyFileEntry -Path $machineDir -Key $regPath18 -ValueName 'MSAOptional'                                  -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Application Compatibility
    Set-PolicyFileEntry -Path $machineDir -Key $regPath19 -ValueName 'AITEnable'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath19 -ValueName 'DisableInventory'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath19 -ValueName 'DisableUAR'                                   -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > AutoPlay Policies
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoDriveTypeAutoRun'                           -Data '255'   -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'NoAutoplayfornonVolume'                       -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath06 -ValueName 'NoAutorun'                                    -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > BitLocker Drive Encryption > Fixed drives
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'FDVEncryptionType'                            -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'FDVRecovery'                                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'FDVManageDRA'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'FDVActiveDirectoryBackup'                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'FDVAllowUserCert'                             -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > BitLocker Drive Encryption > OS drive
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'OSEncryptionType'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'UseAdvancedStartup'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'EnableBDEWithNoTPM'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'UseTPM'                                       -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'UseTPMKey'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'UseTPMKeyPIN'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'UseTPMPIN'                                    -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'UseEnhancedPin'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'OSRecovery'                                   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'OSManageDRA'                                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'OSRecoveryKey'                                -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'OSRecoveryPassword'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath50 -ValueName 'OSActiveDirectoryBackup'                      -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Chat
    Set-PolicyFileEntry -Path $machineDir -Key $regPath20 -ValueName 'ChatIcon'                                     -Data '3'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Cloud Content
    Set-PolicyFileEntry -Path $machineDir -Key $regPath21 -ValueName 'DisableSoftLanding'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath21 -ValueName 'DisableWindowsConsumerFeatures'               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds
    Set-PolicyFileEntry -Path $machineDir -Key $regPath22 -ValueName 'AllowBuildPreview'                            -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath23 -ValueName 'AllowTelemetry'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath23 -ValueName 'DisableTelemetryOptInSettingsUx'              -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath23 -ValueName 'LimitDiagnosticLogCollection'                 -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath23 -ValueName 'LimitDumpCollection'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath23 -ValueName 'DoNotShowFeedbackNotifications'               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Desktop Window Manager
    Set-PolicyFileEntry -Path $machineDir -Key $regPath24 -ValueName 'DisableAccentGradient'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath24 -ValueName 'DisallowAnimations'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Edge UI
    Set-PolicyFileEntry -Path $machineDir -Key $regPath25 -ValueName 'AllowEdgeSwipe'                               -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath25 -ValueName 'DisableHelpSticker'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > File Explorer
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'ExplorerRibbonStartsMinimized'                -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath10 -ValueName 'DisableGraphRecentItems'                      -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Location and Sensors
    Set-PolicyFileEntry -Path $machineDir -Key $regPath26 -ValueName 'DisableLocation'                              -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath26 -ValueName 'DisableLocationScripting'                     -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Maps
    Set-PolicyFileEntry -Path $machineDir -Key $regPath27 -ValueName 'AutoDownloadAndUpdateMapData'                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath27 -ValueName 'AllowUntriggeredNetworkTrafficOnSettingsPage' -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft accounts
    Set-PolicyFileEntry -Path $machineDir -Key $regPath28 -ValueName 'DisableUserAuth'                              -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus
    Set-PolicyFileEntry -Path $machineDir -Key $regPath29 -ValueName 'PUAProtection'                                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft Edge
    Set-PolicyFileEntry -Path $machineDir -Key $regPath30 -ValueName 'ShowOneBox'                                   -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath31 -ValueName 'FlashPlayerEnabled'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath32 -ValueName 'AllowConfigurationUpdateForBooksLibrary'      -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'AllowFullScreenMode'                          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'AllowPrelaunch'                               -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath34 -ValueName 'AllowTabPreloading'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath30 -ValueName 'AllowWebContentOnNewTabPage'                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'Use FormSuggest'                              -Data 'no'    -Type 'String'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'ConfigureFavoritesBar'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath35 -ValueName 'ConfigureHomeButton'                          -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'AllowPopups'                                  -Data 'yes'   -Type 'String'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath36 -ValueName 'ShowSearchSuggestionsGlobal'                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'SyncFavoritesBetweenIEAndMicrosoftEdge'       -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'PreventLiveTileDataCollection'                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath33 -ValueName 'PreventFirstRunPage'                          -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > OneDrive
    Set-PolicyFileEntry -Path $machineDir -Key $regPath38 -ValueName 'PreventNetworkTrafficPreUserSignIn'           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath39 -ValueName 'DisableFileSyncNGSC'                          -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections
    Set-PolicyFileEntry -Path $machineDir -Key $regPath40 -ValueName 'fDenyTSConnections'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Search
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'AllowCloudSearch'                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'AllowCortanaAboveLock'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'AllowCortana'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'SearchOnTaskbarMode'                          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'DisableWebSearch'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'ConnectedSearchUseWeb'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'ConnectedSearchPrivacy'                       -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath41 -ValueName 'ConnectedSearchSafeSearch'                    -Data '3'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Store
    Set-PolicyFileEntry -Path $machineDir -Key $regPath42 -ValueName 'DisableOSUpgrade'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath42 -ValueName 'AutoDownload'                                 -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Widgets
    Set-PolicyFileEntry -Path $machineDir -Key $regPath43 -ValueName 'AllowNewsAndInterests'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath43 -ValueName 'DisableWidgetsOnLockScreen'                   -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Game Recording and Broadcasting
    Set-PolicyFileEntry -Path $machineDir -Key $regPath44 -ValueName 'AllowGameDVR'                                 -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Hello for Business
    Set-PolicyFileEntry -Path $machineDir -Key $regPath45 -ValueName 'Enabled'                                      -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Ink Workspace
    Set-PolicyFileEntry -Path $machineDir -Key $regPath46 -ValueName 'AllowWindowsInkWorkspace'                     -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Media Player
    Set-PolicyFileEntry -Path $machineDir -Key $regPath47 -ValueName 'QuickLaunchShortcut'                          -Data 'no'    -Type 'String'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Messenger
    Set-PolicyFileEntry -Path $machineDir -Key $regPath48 -ValueName 'PreventRun'                                   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $machineDir -Key $regPath48 -ValueName 'PreventAutoRun'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Remote Shell
    Set-PolicyFileEntry -Path $machineDir -Key $regPath49 -ValueName 'AllowRemoteShellAccess'                       -Data '0'     -Type 'DWord'

    # ===========
    # User Config
    # ===========

    $userDir = "$env:windir\System32\GroupPolicy\User\Registry.pol"

    $regPath50 = 'Software\Policies\Microsoft\Windows\Control Panel\Desktop'
    $regPath51 = 'Software\Policies\Microsoft\InputPersonalization'
    $regPath52 = 'Software\Policies\Microsoft\Control Panel\Desktop'
    $regPath53 = 'Software\Policies\Microsoft\Control Panel\International'
    $regPath54 = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $regPath55 = 'Software\Policies\Microsoft\Windows\Explorer'
    $regPath56 = 'Software\Policies\Microsoft\Assistance\Client\1.0'
    $regPath57 = 'Software\Policies\Microsoft\Messenger\Client'
    $regPath58 = 'Software\Policies\Microsoft\Windows\CloudContent'
    $regPath59 = 'Software\Policies\Microsoft\Windows\DataCollection'
    $regPath60 = 'Software\Policies\Microsoft\Windows\DWM'
    $regPath61 = 'Software\Policies\Microsoft\Windows\EdgeUI'
    $regPath62 = 'Software\Policies\Microsoft\ime\imejp'
    $regPath63 = 'Software\Policies\Microsoft\ime\shared'
    $regPath64 = 'Software\Policies\Microsoft\Windows\LocationAndSensors'
    $regPath65 = 'Software\Policies\Microsoft\MicrosoftEdge\ServiceUI'
    $regPath66 = 'Software\Policies\Microsoft\MicrosoftEdge\Addons'
    $regPath67 = 'Software\Policies\Microsoft\MicrosoftEdge\BooksLibrary'
    $regPath68 = 'Software\Policies\Microsoft\MicrosoftEdge\Main'
    $regPath69 = 'Software\Policies\Microsoft\MicrosoftEdge\TabPreloader'
    $regPath70 = 'Software\Policies\Microsoft\MicrosoftEdge\Internet Settings'
    $regPath71 = 'Software\Policies\Microsoft\MicrosoftEdge\SearchScopes'
    $regPath72 = 'Software\Policies\Microsoft\WindowsStore'
    $regPath73 = 'Software\Policies\Microsoft\Windows\WindowsCopilot'
    $regPath74 = 'Software\Policies\Microsoft\Windows\Windows Error Reporting'
    $regPath75 = 'Software\Policies\Microsoft\PassportForWork'
    $regPath76 = 'Software\Policies\Microsoft\Messenger\Client'

    # User Configuration > Administrative Templates > Control Panel > Personalization
    Set-PolicyFileEntry -Path $userDir -Key $regPath50 -ValueName 'ScreenSaveActive'                                               -Data '0'        -Type 'String'
    # User Configuration > Administrative Templates > Control Panel > Regional and Language Options
    Set-PolicyFileEntry -Path $userDir -Key $regPath52 -ValueName 'PreferredUILanguages'                                           -Data 'en-US'    -Type 'String'
    Set-PolicyFileEntry -Path $userDir -Key $regPath52 -ValueName 'MultiUILanguageID'                                              -Data '00000409' -Type 'String'
    Set-PolicyFileEntry -Path $userDir -Key $regPath53 -ValueName 'RestrictLanguagePacksAndFeaturesInstall'                        -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath53 -ValueName 'TurnOffAutocorrectMisspelledWords'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath53 -ValueName 'TurnOffHighlightMisspelledWords'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath53 -ValueName 'TurnOffOfferTextPredictions'                                    -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Control Panel > Regional and Language Options > Handwriting personalization
    Set-PolicyFileEntry -Path $userDir -Key $regPath51 -ValueName 'RestrictImplicitTextCollection'                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath51 -ValueName 'RestrictImplicitInkCollection'                                  -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Desktop
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoInternetIcon'                                                 -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Start Menu and Taskbar
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'ClearRecentDocsOnExit'                                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'ClearRecentProgForNewUserInStartMenu'                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoRecentDocsHistory'                                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'ForceStartSize'                                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'HideTaskViewButton'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'LockTaskbar'                                                    -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoTaskGrouping'                                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'HideRecentlyAddedApps'                                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoStartMenuMFUprogramsList'                                     -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'HideRecommendedPersonalizedSites'                               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'TaskbarNoPinnedList'                                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoStartMenuPinnedList'                                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoRecentDocsMenu'                                               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'HideRecommendedSection'                                         -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'HideSCAMeetNow'                                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'HidePeopleBar'                                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'ShowOrHideMostUsedApps'                                         -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'ShowWindowsStoreAppsOnTaskbar'                                  -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoAutoTrayNotify'                                               -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > System > Internet Communication Management > Internet Communication settings
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'NoUseStoreOpenWith'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath56 -ValueName 'NoImplicitFeedback'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoWebServices'                                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoInternetOpenWith'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoOnlinePrintsWizard'                                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoPublishingWizard'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath57 -ValueName 'CEIP'                                                           -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath56 -ValueName 'NoOnlineAssist'                                                 -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > AutoPlay Policies
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoAutorun'                                                      -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoDriveTypeAutoRun'                                             -Data '255'      -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'NoAutoplayfornonVolume'                                         -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Cloud Content
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'ConfigureWindowsSpotlight'                                      -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableThirdPartySuggestions'                                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableTailoredExperiencesWithDiagnosticData'                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableWindowsSpotlightFeatures'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableSpotlightCollectionOnDesktop'                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableWindowsSpotlightWindowsWelcomeExperience'                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableWindowsSpotlightOnActionCenter'                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath58 -ValueName 'DisableWindowsSpotlightOnSettings'                              -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds
    Set-PolicyFileEntry -Path $userDir -Key $regPath59 -ValueName 'AllowTelemetry'                                                 -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Desktop Window Manager
    Set-PolicyFileEntry -Path $userDir -Key $regPath60 -ValueName 'DisallowAnimations'                                             -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Edge UI
    Set-PolicyFileEntry -Path $userDir -Key $regPath61 -ValueName 'AllowEdgeSwipe'                                                 -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath61 -ValueName 'DisableHelpSticker'                                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath61 -ValueName 'DisableRecentApps'                                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath61 -ValueName 'DisableCharms'                                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath61 -ValueName 'TurnOffBackstack'                                               -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > File Explorer
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'MaxRecentDocs'                                                  -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'NoSearchInternetTryHarderButton'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'NoChangeAnimation'                                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'ExplorerRibbonStartsMinimized'                                  -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath54 -ValueName 'TurnOffSPIAnimations'                                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'DisableSearchBoxSuggestions'                                    -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > IME
    Set-PolicyFileEntry -Path $userDir -Key $regPath62 -ValueName 'UseHistorybasedPredictiveInput'                                 -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath63 -ValueName 'SearchPlugin'                                                   -Data '0'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Location and Sensors
    Set-PolicyFileEntry -Path $userDir -Key $regPath64 -ValueName 'DisableLocation'                                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath64 -ValueName 'DisableLocationScripting'                                       -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Microsoft Edge
    Set-PolicyFileEntry -Path $userDir -Key $regPath65 -ValueName 'ShowOneBox'                                                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath66 -ValueName 'FlashPlayerEnabled'                                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath67 -ValueName 'AllowConfigurationUpdateForBooksLibrary'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'AllowFullScreenMode'                                            -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'AllowPrelaunch'                                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath69 -ValueName 'AllowTabPreloading'                                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath65 -ValueName 'AllowWebContentOnNewTabPage'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'Use FormSuggest'                                                -Data 'no'    -Type 'String'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'ConfigureFavoritesBar'                                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath70 -ValueName 'ConfigureHomeButton'                                            -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'AllowPopups'                                                    -Data 'yes'   -Type 'String'
    Set-PolicyFileEntry -Path $userDir -Key $regPath71 -ValueName 'ShowSearchSuggestionsGlobal'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'SyncFavoritesBetweenIEAndMicrosoftEdge'                         -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'PreventLiveTileDataCollection'                                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath68 -ValueName 'PreventFirstRunPage'                                            -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Search
    Set-PolicyFileEntry -Path $userDir -Key $regPath55 -ValueName 'DisableSearchHistory'                                           -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Store
    Set-PolicyFileEntry -Path $userDir -Key $regPath72 -ValueName 'DisableOSUpgrade'                                               -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Copilot
    Set-PolicyFileEntry -Path $userDir -Key $regPath73 -ValueName 'TurnOffWindowsCopilot'                                          -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Error Reporting
    Set-PolicyFileEntry -Path $userDir -Key $regPath74 -ValueName 'Disabled'                                                       -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Hello for Business
    Set-PolicyFileEntry -Path $userDir -Key $regPath75 -ValueName 'Enabled'                                                        -Data '0'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Messenger
    Set-PolicyFileEntry -Path $userDir -Key $regPath76 -ValueName 'PreventRun'                                                     -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $userDir -Key $regPath76 -ValueName 'PreventAutoRun'                                                 -Data '1'     -Type 'DWord'

    Start-Sleep -Seconds 5
    gpupdate /force
}

function Set-UIPreferences {
    $explorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    $explorerAdvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

    # dark mode
    Write-Message 'Setting Windows dark mode...'
    Set-ItemProperty -Path $personalize -Name AppsUseLightTheme -Value 0
    Set-ItemProperty -Path $personalize -Name SystemUsesLightTheme -Value 0

    # hidden files
    Write-Message 'Show hidden files...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'Hidden' -Value 1

    # file extentions
    Write-Message 'Show file extentions...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'HideFileExt' -Value 0

    # Bing search
    Write-Message 'Disabling Bing search...'
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name 'BingSearchEnabled' -Value 0

    # show icons notification area (always show = 0, not showing = 1)
    Write-Message 'Showing all tray icons...'
    Set-ItemProperty -Path $explorer -Name 'EnableAutoTray' -Value 0

    # taskbar alignment
    Write-Message 'Align taskbar to the left...'
    Set-ItemProperty -Path $explorerAdvanced -Name "TaskbarAl" -Value 0

    # taskbar size (small = 1, large = 0)
    Write-Message 'Setting taskbar height size to small...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'TaskbarSmallIcons' -Value 1

    # taskbar combine (always = 0, when full = 1, never = 2)
    Write-Message 'Setting taskbar combine when full mode...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'TaskbarGlomLevel' -Value 1

    # lock taskbar (lock = 0, unlock = 1)
    Write-Message 'Locking the taskbar...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'TaskbarSizeMove' -Value 0

    # disable recent files, folders and cloud files (hidden = 0, show = 1)
    Write-Message 'Disabling recent files and cloud folders...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'CloudFilesOnDemand' -Value 0
    Set-ItemProperty -Path $explorerAdvanced -Name 'Start_TrackDocs' -Value 0
    Set-ItemProperty -Path $explorer -Name 'ShowFrequent' -Value 0

    # Start menu layout
    Write-Message 'Setting up the Start menu...'
    Set-ItemProperty -Path $explorerAdvanced -Name 'Start_Layout' -Value 1 # (1 = More pins, 2 = More recommendations, 3 = Default)

    # disable transparency (1 = enabled, 0 = disabled)
    Write-Message 'Disabling transparency effects...'
    Set-ItemProperty -Path $personalize -Name 'EnableTransparency' -Value 0

    # sticky keys
    Write-Message 'Disabling sticky keys...'
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name Flags -Value 58

    # snap windows
    Write-Message 'Disabling snapping of windows on startup...'
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WindowArrangementActive -Value 0
    Write-Message 'Disabling snap assist suggestion on startup...'
    Set-ItemProperty -Path $explorerAdvanced -Name WindowArrangementActive -Value 0
    Write-Message 'Disabling snap assist flyout on startup...'
    Set-ItemProperty -Path $explorerAdvanced -Name EnableSnapAssistFlyout -Value 0

    # recall
    Write-Message "Disabling Recall..."
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsAI" -Name 'DisableAIDataAnalysis' -Value 1
    DISM /Online /Disable-Feature /FeatureName:Recall

    # screenshot folder
    Write-Message 'Setting the screenshot folder to Desktop...'
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}' -Value "$env:USERPROFILE\Desktop"

    # region
    if (Ask-Question 'Set timezone/currency/timeformat to fr-FR?') {
        Set-TimeZone -Name 'Romance Standard Time'
        Set-Culture fr-FR
    }

    # openssh
    Write-Message 'Enabling OpenSSH at startup...'
    Set-Service ssh-agent -StartupType Automatic

    # no sound settings
    Write-Message 'Switching Sound Scheme to no sounds...'
    New-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name '(Default)' -Value '.None' -Force | Out-Null
    Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" -Recurse | Where-Object { $_.PSChildName -eq '.Current' } | Set-ItemProperty -Name '(Default)' -Value ''

    Write-Message 'Turning Windows Startup sound off...'
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name 'DisableStartupSound' -Value 1 -Type DWord -Force

    Stop-Process -Name explorer -Force
    Write-Message 'Might need to relog for changes to take effect.'

    # keyboard settings
    $languageList = Get-WinUserLanguageList

    if (-not $languageList | Where-Object { $_.InputMethodTips -contains "0409:0000040C" }) {
        if (Ask-Question 'FR keyboard layout not detected, install?') {
            Write-Message 'Adding FR keyboard layout...'
            $languageList[0].InputMethodTips.Add('0409:0000040C')
            Set-WinUserLanguageList $languageList -Force
            Set-WinDefaultInputMethodOverride -InputTip "0409:0000040C"
        }
    }

    if (Ask-Question 'Remap ctrl to capslock key?') {
        $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
        $kbLayout = "HKLM:\System\CurrentControlSet\Control\Keyboard Layout";

        New-ItemProperty -Path $kbLayout -Name 'Scancode Map' -PropertyType Binary -Value ([byte[]]$hexified);

        Write-Message 'You need to reboot to take effect.'
    }

    # mouse settings
    Write-Message 'Disabling mouse acceleration...'
    $mousePath = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $mousePath -Name MouseSpeed -Value 0
    Set-ItemProperty -Path $mousePath -Name MouseThreshold1 -Value 0
    Set-ItemProperty -Path $mousePath -Name MouseThreshold2 -Value 0
}

function Enable-BitLocker {
    if (Ask-Question 'Encrypt C: drive?') {
        manage-bde -protectors -add c: -TPMAndPIN
        Start-Sleep -Seconds 3
        manage-bde -on c: -RecoveryPassword
    }

    $drives = (BitlockerVolume | Where-Object {$_.AutoUnlockEnabled -eq $false}).MountPoint

    if ($drives) {
        foreach ($drive in $drives) {
            if (Ask-Question "Automatically unlock $drive at boot?") {
                manage-bde -unlock "$drive" -password
                Start-Sleep -Seconds 10
                manage-bde -autounlock -enable "$drive"
            }
        }
    }
}

function Set-FireWall {
    if (Ask-Question 'Block incoming connections and allow outgoing?') {
        Set-NetConnectionProfile -NetworkCategory Private
        netsh advfirewall set allprofiles state on
        netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set publicprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set privateprofile firewallpolicy blockinboundalways,allowoutbound
    }
}

function Set-PowerSettings {
    Write-Message 'Turning off all power saving mode when on AC power...'
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0

    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem

    if ($computerSystem.PCSystemType -eq 2) {
        Write-Message 'Running on a laptop, keeping hibernate on...'
    } else {
        Write-Message 'Turning hibernate off...'
        powercfg.exe /HIBERNATE off
    }
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

    if (Ask-Question 'Install WinGet from GitHub (instead of Microsoft Store)?') {
        $apiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $downloadUrl = $(Invoke-RestMethod $apiUrl).assets.browser_download_url |
          Where-Object {$_.EndsWith(".msixbundle")}

        Invoke-WebRequest -Uri $downloadUrl -OutFile "winget.msixbundle" -UseBasicParsing
        Add-AppxPackage -Path "winget.msixbundle"
        Remove-Item "winget.msixbundle" }

    Write-Message 'Updating sources list...'
    winget source update

    foreach ($p in $packages) {
        if (Ask-Question "Install ${p}?") { winget install -e --id "$p" }
    }

    if (Ask-Question 'Install Emacs?') {
        winget install -e --id 'GNU.Emacs'
        winget install -e --id 'FSFhu.Hunspell'

        Write-Message 'Excluding Emacs from AV scanning to improve performance...'
        Add-MpPreference -ExclusionPath 'C:\Program Files\Emacs', "$env:APPDATA\.emacs.d"
        Add-MpPreference -ExclusionProcess "C:\Program Files\Emacs\*", 'runemacs.exe', 'emacs.exe', 'emacsclientw.exe', 'emacsclient.exe'
        Add-MpPreference -ExclusionExtension ".el", ".elc", ".eln"

        Write-Message 'Downloading English and French dictionaries for Flyspell...'
        $hunspellDir = "$env:APPDATA\.emacs.d\hunspell"
        New-Item -Force -Path "$hunspellDir" -ItemType directory

        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff' -OutFile "$hunspellDir\en_US.aff"
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.dic' -OutFile "$hunspellDir\en_US.dic"
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/fr_FR/fr.aff' -OutFile "$hunspellDir\fr_FR.aff"
        Invoke-WebRequest -Uri 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/fr_FR/fr.dic' -OutFile "$hunspellDir\fr_FR.dic"
    }

    if (Ask-Question 'Install Git?') {
        winget install -e --id Git.Git --custom '/o:Components=icons,gitlfs /o:PathOption=CmdTools /o:SSHOption=ExternalOpenSSH /o:CRLFOption=CRLFCommitAsIs /o:CURLOption=WinSSL'
    }

    if (Ask-Question 'Install MKVToolNix?') {
        winget install -e --id 'MoritzBunkus.MKVToolNix'

        Write-Message 'Adding MKVToolNix to path...'
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";C:\Program Files\MKVToolNix", [EnvironmentVariableTarget]::User)
    }

    if (Ask-Question 'Install qBittorrent?') {
        winget install -e --id 'qBittorrent.qBittorrent'

        $pluginDir = "$HOME\AppData\Local\qBittorrent\nova3\engines"
        New-Item -Force -Path "$pluginDir" -ItemType directory

        $urls = @(
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
        foreach ($url in $urls) {
            $fileName = [System.IO.Path]::GetFileName($url)
            $outFile = Join-Path $pluginDir $fileName
            Invoke-WebRequest -Uri $url -OutFile $outFile
        }
    }

    if (Ask-Question 'Install Tor Browser?') {
        winget install -e --id 'TorProject.TorBrowser'

        Start-Sleep -Seconds 5

        Write-Message 'Moving install folder to Program Files...'
        Move-Item -Path "$HOME\Desktop\Tor Browser" -Destination 'C:\Program Files\'

        Write-Message 'Creating Shortcut for Start Menu...'
        $targetFilePath = 'C:\Program Files\Tor Browser\Browser\firefox.exe'
        $shortcutLocation = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Tor Browser.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutLocation)
        $shortcut.TargetPath = $targetFilePath
        $shortcut.Save()
    }

    if (Ask-Question 'Install iCloud?') {
        winget install --source msstore 9PKTQ5699M62
    }
}

function Install-MPV {
    Write-Message 'Creating variables and folders...'
    $downloadDest = "$tempFolder\mpv.zip"
    $installDest = 'C:\Program Files'
    $configDest = "$env:APPDATA\mpv"

    # New-Item -Force -Path "$installDest" -ItemType directory
    New-Item -Force -Path "$configDest" -ItemType directory
    New-Item -Force -Path "$configDest\fonts" -ItemType directory
    New-Item -Force -Path "$configDest\scripts" -ItemType directory
    New-Item -Force -Path "$configDest\scripts\uosc" -ItemType directory

    Write-Message 'Installing latest mpv...'
    Invoke-WebRequest -Uri 'https://github.com/shinchiro/mpv-packaging/archive/refs/heads/master.zip' -OutFile "$downloadDest"
    Expand-Archive -Path "$tempFolder\mpv.zip" -DestinationPath "$installDest"
    Rename-Item -Path "$installDest\mpv-packaging-master" -NewName "mpv"

    Write-Message 'Adding mpv to path...'
    [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$installDest\mpv\mpv-root", [EnvironmentVariableTarget]::User)

    & "$installDest\mpv\mpv-root\updater.bat"
    & "$installDest\mpv\mpv-root\installer\mpv-install.bat"

    Remove-Item "$tempFolder\mpv.zip"

    Write-Message 'Installing plugins...'

    Invoke-WebRequest -Uri 'https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip' -OutFile "$tempFolder\uosc.zip"
    Expand-Archive -Path "$tempFolder\uosc.zip" -DestinationPath "$configDest"

    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua' -OutFile "$configDest\scripts\thumbfast.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/mfcc64/mpv-scripts/master/visualizer.lua' -OutFile "$configDest\scripts\visualizer.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/crop.lua' -OutFile "$configDest\scripts\crop.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/encode.lua' -OutFile "$configDest\scripts\encode.lua"

    Remove-Item "$tempFolder\uosc.zip"
}

function Install-Findutils {
    Write-Message 'Creating variables and folders...'
    $downloadDest = "$tempFolder\findutils.pkg.tar.zst"
    $installDest = "C:\Program Files\GnuFindutils"

    Write-Message 'Downloading findutils...'
    Invoke-WebRequest -Uri 'https://mirror.msys2.org/msys/x86_64/findutils-4.10.0-2-x86_64.pkg.tar.zst' -OutFile "$downloadDest"

    Write-Message 'Extracting...'
    New-Item -Force -Path "$installDest" -ItemType directory
    tar --extract --file="$downloadDest" --directory="$installDest"

    Write-Message 'Adding binaries to the path...'
    [Environment]::SetEnvironmentVariable("Path", "$installDest\usr\bin;" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine), [EnvironmentVariableTarget]::Machine)

    Remove-Item "$downloadDest"
}

function Run-Massgrave {
    irm 'https://get.activated.win' | iex
}

function Set-Git {
    Push-Location
    cd "${HOME}/dotfiles"

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
}

function usage {
    Write-Host
    Write-Host 'Usage:'
    Write-Host '  gpo             - apply machine and user group policies'
    Write-Host '  uiuxprefs       - explorer, taskbar, keyboard and other preferences'
    Write-Host '  bitlocker       - change Group Policy settings for BitLocker and encrypts C:'
    Write-Host '  firewall        - firewall rules: block incoming, allow outgoing'
    Write-Host '  powermngmt      - disable power saving modes on AC power'
    Write-Host '  winget_packages - download and install listed packages with winget'
    Write-Host '  mpv             - install mpv'
    Write-Host '  findutils       - install GNU Findutils'
    Write-Host '  activate        - run massgrave activation script'
    Write-Host '  git             - set correct SSH origin for this repository'
    Write-Host
}

function main {
    $cmd = $args[0]

    # return error if nothing is specified
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq 'gpo')                 { Apply-GPO }
    elseif ($cmd -eq 'uiuxprefs')       { Set-UIPreferences }
    elseif ($cmd -eq 'bitlocker')       { Enable-BitLocker }
    elseif ($cmd -eq 'firewall')        { Set-FireWall }
    elseif ($cmd -eq 'powermngmt')      { Set-PowerSettings }
    elseif ($cmd -eq 'winget_packages') { Install-WinGet }
    elseif ($cmd -eq 'mpv')             { Install-MPV }
    elseif ($cmd -eq 'findutils')       { Install-Findutils }
    elseif ($cmd -eq 'activate')        { Run-Massgrave }
    elseif ($cmd -eq 'git')             { Set-Git }
    else { usage }
}

main $args[0]
