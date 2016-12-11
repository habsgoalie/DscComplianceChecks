
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,
        
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$AutomationAccountName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Recipient,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$MailServer,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Sender,

    [Parameter(Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()]
    $Credential
)

$Name = "AzureRM"
$Module = Get-Module -Listavailable |  Where-object { $_.Name.Contains($Name) }
If(!($Module)){
	Install-Module $Name -Force
    Import-Module -Name $Name
}
Else{
    Import-Module -Name $Name
}

Login-AzureRmAccount -Credential $Credential

$Nodes = Get-AzureRmAutomationDscNode -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName

Function Check-Unresponsive{
    $Unresponsive = ForEach($Node in $Nodes){
        If($Node.Status -eq "unresponsive"){
            $Node
        }
    }
    If($Unresponsive){
        $Body = $Unresponsive | Out-String
        Send-Mailmessage -to $Recipient -Subject "DSC Check - Unresponsive Node(s)" -from $Sender -Body $Body -SmtpServer $MailServer
    }
}

Function Check-Failed{
    $Failed = ForEach($Node in $Nodes){
        If($Node.Status -eq "failed"){
            $Node
        }
    }
    If($Failed){
        $Body = $Failed | Out-String
        Send-Mailmessage -to $Recipient -Subject "DSC Check - Failed Node(s)" -from $Sender -Body $Body -SmtpServer $MailServer
    }
}
Check-Unresponsive
Check-Failed
