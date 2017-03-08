﻿# this is a Pester test file

#region Further Reading
# http://www.powershellmagazine.com/2014/03/27/testing-your-powershell-scripts-with-pester-assertions-and-more/
#endregion
#region LoadScript
# load the script file into memory
# attention: make sure the script only contains function definitions
# and no active code. The entire script will be executed to load
# all functions into memory
#. ($PSCommandPath -replace '\.tests\.ps1$', '.ps1')
#endregion


#Describe 'Testing against PSSA rules' {
#	Context 'PSSA Standard Rules' {
#		$analysis = Invoke-ScriptAnalyzer -Path '.\sqlinstallation.ps1' -ExcludeRule PSAvoidUsingWriteHost
#		$scriptAnalyzerRules = Get-ScriptAnalyzerRule
#		forEach ($rule in $scriptAnalyzerRules) {
#			It "Should pass $rule" {
#				If ($analysis.RuleName -contains $rule) {
#					$analysis |
#					Where-Object -Property RuleName -EQ -Value $rule -OutVariable failures |
#					Out-Default
#					$failures.Count | Should Be 0
#				}
#			}
#		}
#	}
#}

# describes the function Test-WSManCredSSP
Describe -Name 'Test-WSManCredSSP' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {
        it -Name 'WSMANCredSSP is enabled should outupt $true' -test {
            mock get-item {$true}
        }
	}
}

# Test if feature is or is not installed and take action 
Describe -Name 'Test-WindowsFeature' -Fixture {
	$actionCase = @(
		@{
			action  = 'Install'
			TestCase = 'Install'
		}
		@{
			action  = 'Uninstall'
			TestCase = 'Uninstall'
		}
	)
	Context -Name 'Input' -Fixture {
		$parameterInfo = (Get-Command Test-WindowsFeature).Parameters['ComputerName']
		It -name 'Parameter ComputerName Should be of type String' -test {
			$parameterInfo.ParameterType.Name | Should Be 'String'
		}
    
		$parameterInfo = (Get-Command Test-WindowsFeature).Parameters['Name']

		It -name 'Parameter Name Should be of type String' -test {
			$parameterInfo.ParameterType.Name | Should Be 'String'
		}

		$parameterInfo = (Get-Command Test-WindowsFeature).Parameters['action']
		It -name 'Has ValidateSet for parameter Install-SQL for input Sql installationstyp' -test {
			$parameterInfo.Attributes.Where{
				$_ -is [ValidateSet]
			}.Count | Should be 1
		}
		It -name 'Should be of type String' -test {
			$parameterInfo.ParameterType.Name | Should Be 'String'
		}
		It -name 'ValidateSet contains option <TestCase>' -TestCases $actionCase -test {
			param($action)
			$parameterInfo.Attributes.ValidValues -contains $action | Should be $true
		}
	}

	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {
        # Test when installing Windows feature       
		It -name 'When installing a feature and its installed: ' -test {
            Mock Get-WindowsFeature { 
                [PSCustomObject]@{Installed = $true} 
            }
			Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER has feature FEATURENAME Installed'
		}

        It -name 'When installing a feature and SXS folder does not exist: ' -test {
            mock 
        }
		It -name 'When installing a feature and installed and succesfully: ' -test {
            Mock Get-WindowsFeature { 
                [PSCustomObject]@{Installed = $false} 
            }
            Mock Install-WindowsFeature {
                [PSCustomObject]@{Exitcode = 'Success'} 
            }

			Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER got feature FEATURENAME Installed'
		}

        It -name 'When installing a feature and installation failes: ' -test {
            Mock Get-WindowsFeature { 
                [PSCustomObject]@{Installed = $false} 
            }
            Mock Install-WindowsFeature {
                [PSCustomObject]@{Installed = $false} 
            }
			Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be ' SERVER has feature FEATURENAME Installed'
		}

        # Test when uninstalling windows feature
		It -name 'When uninstalling a feature and its removed: ' -test {
            Mock Get-WindowsFeature { 
                [PSCustomObject]@{Installed = $true} 
            }
			Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER got feature FEATURENAME removed'
		}

		It -name 'When uninstalling a feature and it failes' -test {
            Mock Get-WindowsFeature { 
                [PSCustomObject]@{Installed = $true} 
            }
			Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER failed to remove feature FEATURENAME'
		}

        It -name 'When uninstalling a feature and its not installed' -test {
            Mock Get-WindowsFeature { 
                [PSCustomObject]@{Installed = $true} 
            }
			Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER does not have feature FEATURENAME Installed'
		}
	}
}

Describe -Name 'Get-SQLBackupFolder' -Fixture {
    #Should use testcase
	Context -Name 'Input' -Fixture {
        It -name 'Only allow a singel computer' {}
        It -name 'Only allow the strings "Prod","Acc" and "Test" to be used for env' {}
        It -name 'Should be a string with the base backupfolder' {}
	}
	Context -Name 'Execution' -Fixture {
        It -name 'Should add account to group Get-SQLBackupFolder' {}
	}
	Context -Name 'Output' -Fixture {
        it -name 'Should output the sql backupfolder for the server to use' {}
	}
}


Describe -Name 'Set-SQLGroup' -Fixture {
    # Testcase
	Context -Name 'Input' -Fixture {
        It -name 'Parameter ComputerName: Only allow a singel computer' {}
        It -name 'Only allow the strings "Prod","Acc" and "Test" to be used for env' {}
	}
	Context -Name 'Execution' -Fixture {
        It -name 'Should add account to group Set-SQLGrop:' {}
	}
	Context -Name 'Output' -Fixture {
        
	}
}

Describe -Name 'Set-SQLDisks' -Fixture {
	Context -Name 'Input' -Fixture {
        It -name 'Parameter ComputerName: Only allow a singel computer' {}
        It -name 'Parameter UserObj: Should Throw if not credential object' {}
        It -name 'Parameter UserObj: Only allow credential object' {}
	}
	Context -Name 'Execution' -Fixture {
        It -name 'Should create a cim session to the computer'
        It -name 'Should get disk through the cimsession that is online: Ends' {}
        # How to test a long chain of piping 
        # On done on the cim session
        It 'Should get disk that is offline and set them online' {}
        It 'Should get disk that is readonly and set them readwrite'{}
        It 'Should get disk that is raw and create partition and format the disk' {}
        It 'Should set partition on disk 1'{}
        It 'Should set partition on disk 2'{}
        It 'Should set partition on disk 3'{}
        It 'Should throw if any error setting up disk on computer:' {}
        It 'Should remove cim session' {}
	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Test-SQL' -Fixture {
	Context -Name 'Input' -Fixture {
        $parameterInfo = (Get-Command Test-SQL).Parameters['Computername']
		It -name 'Has ValidateSet for parameter Install-SQL for input Sql installationstyp' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Wait-SQLService' -Fixture {
	Context -Name 'Input' -Fixture {
        
	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Install-SQL' -Fixture {
	$envCase = @(
		@{
			env   = 'Test'
			TestName = 'Test'
		}
		@{
			env   = 'Acc'
			TestName = 'Acc'
		}
		@{
			env   = 'Prod'
			TestName = 'Prod'
		}
	)
	$SqlCase = @(
		@{
			Sql   = 'Default'
			TestName = 'Default'
		}
		@{
			Sql   = 'AO'
			TestName = 'AO'
		}
		@{
			Sql   = 'Latin'
			TestName = 'Latin'
		}
		@{
			Sql   = 'SSRS'
			TestName = 'SSRS'
		}
		@{
			Sql   = 'SSASM'
			TestName = 'SSASM'
		}
		@{
			Sql   = 'SSIS'
			TestName = 'SSIS'
		}
		@{
			Sql   = 'SSAST'
			TestName = 'SSAST'
		}
		@{
			Sql   = 'SP'
			TestName = 'SP'
		}
		@{
			Sql   = 'SCOM'
			TestName = 'SCOM'
		}
	)
	$VersionCase = @(
		@{
			Version = '2008'
			TestName = '2008'
		}
		@{
			Version = '2012'
			TestName = '2012'
		}
		@{
			Version = '2014'
			TestName = '2014'
		}
		@{
			Version = '2016'
			TestName = '2016'
		}
	)
	$EditionCase = @(
		@{
			Edition   = 'Ent'
			TestName = 'Ent'
		}
		@{
			Edition   = 'Std'
			TestName = 'Std'
		}
	)

	Context -Name 'Input' -Fixture {
		#Parameter testing
		$parameterInfo = (Get-Command Install-SQL).Parameters['sql']
		It -name 'Has ValidateSet for parameter Install-SQL for input Sql installationstyp' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
		
		It -name 'ValidateSet contains option <TestName>' -TestCases $SqlCase -test {
			param($sql)
			$parameterInfo.Attributes.ValidValues -contains $sql | Should be $true
		}
		
		$parameterInfo = (Get-Command Install-SQL).Parameters['version']
		It -name 'Has ValidateSet for parameter Install-SQL for input Version' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
		
		It -name 'ValidateSet contains option <TestName>' -TestCases $VersionCase -test {
			param($version)
			(Get-Command Install-SQL).Parameters['Version'].Attributes.ValidValues -contains $version | Should be $true
		}

		$parameterInfo = (Get-Command Install-SQL).Parameters['Edition']
		It -name 'Has ValidateSet for parameter Install-SQL for input Edition' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
		
		It -name 'ValidateSet contains option <TestName>' -TestCases $EditionCase -test {
			param($Edition)
			(Get-Command Install-SQL).Parameters['Edition'].Attributes.ValidValues -contains $Edition | Should be $true
		}

		$parameterInfo = (Get-Command Install-SQL).Parameters['env']
		It -name 'Has ValidateSet for parameter Install-SQL for input enviroment' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
		
		It -name 'ValidateSet contains option <TestName>' -TestCases $envCase -test {
			param($env)
			(Get-Command Install-SQL).Parameters['env'].Attributes.ValidValues -contains $env | Should be $true
		}
		
		It -name 'When server is offline, it will throw an exception' -test {
			Mock -CommandName 'Test-Connection' -MockWith {$false}
			{Install-SQL -server 'IAMOFFLINE'} | Should throw 'could not be reached'
		}

	}
	Context -Name 'Execution' -Fixture {
		mock 'Test-Connection' {$true} 
		mock 'Test-SQL' {$false}
		Mock Test-WSManCredSSP {$true}
		Mock Get-SQLBackupFolder {'\\sodra.com\sql-backup\test\IAMONLINE'} #
        Mock Set-SQLGroup {}
		Mock Invoke-Gpupdate {}
		Mock Test-WindowsFeature {} 
		Mock Restart-Computer {} # How?
		Mock Invoke-Command {}
		Mock Set-SQLDisk {}
		Mock New-PSSession {} # Should this be tested?
		Mock Invoke-Command {} #Its allready mocked should you mock it several times? Or does it use the same mock? Should the scriptblock be tested if yes how?
		Mock Remove-Pssession {}
		Mock Set-location {}
		
		it 'When installing SQL get SQL backupfolder' {
			$null = Install-Sql -server 'IAMONLINE'
			$assMParams = @{
				CommandName = 'Get-SQLBackupFolder'
				Times = 1
				Scope = 'It'
				Exactly = $true
                ParameterFilter = { $ComputerName -eq 'SOMETHING' -and $env -eq 'Test' -and $backupfolder -eq '\\sodra.com\sql-backup'}
			}
			Assert-MockCalled @assMParams	
		}
        it 'When installing SQL set SQLGroup' {
			$null = Install-Sql -server 'IAMONLINE'
			$assMParams = @{
				CommandName = 'Set-SQLGroup'
				Times = 1
				Scope = 'It'
				Exactly = $true
                ParameterFilter = { $ComputerName -eq 'SOMETHING' -and 'Sodra'}
			}
			Assert-MockCalled @assMParams	
		}
	}
	
	Context -Name 'Output' -Fixture {
		
		It 'Server allready have SQL Installed' {
			mock 'Test-Connection' {$true}
			mock 'Test-SQL' {$true}

			{Install-Sql -server 'IAMONLINE'} | Should Throw 'IAMONLINE has running SQL services'
		}	
	}
}