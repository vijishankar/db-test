
[CmdletBinding()]
param(
        $ResourceGroupName,
	$SeverName,
	$KeyVaultName,
	$SecretName
)

 $sqlserver = Get-AzureRmSqlServer -ResourceGroupName $ResourceGroupName
 $keyVault=Get-AzureRMKeyVault -VaultName $keyVaultName -ErrorVariable notPresent -ErrorAction SilentlyContinue
 

function changePassword()
{
if($sqlserver)
{

#Generating Random Password from RandomCharacters Method
$Resetpassword = -join((65..90) + (97..122) + (58..64) + (58..64) + (32..47)  | Get-Random -Count 12 | % {[char]$_})
Write-Host $Resetpassword
Write-Output $Resetpassword


#Updating the password
$SecureStringpwd = ConvertTo-SecureString $Resetpassword -AsPlainText -Force
Set-AzureRmSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SeverName -SqlAdministratorPassword $SecureStringpwd

Write-Host $newpsswd
Write-Output $newpsswd

#Setting Password to the keayvalt
if (!$keyVault)
{
#creating Keyvault in azure
New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $ResourceGroupName -Location $location -SKU $SKU
# assigning Access policies to user
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $ResourceGroupName -EnabledForDeployment
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $ResourceGroupName -EnabledForTemplateDeployment
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $ResourceGroupName -EnabledForDiskEncryption

Set-AzureRmKeyVaultAccessPolicy `
		-VaultName $keyVaultName `
		-ResourceGroupName $ResourceGroupName   `
		-PermissionsToCertificates list,get,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore `
        -PermissionsToKeys decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge `
        -PermissionsToSecrets list,get,set,delete,recover,backup,restore `
		-ServicePrincipalName "89c7c89c-b8cb-4d4c-b7d3-53294cdff2b6"
Set-AzureRmKeyVaultAccessPolicy `
		-VaultName $keyVaultName `
		-ResourceGroupName $ResourceGroupName   `
		-PermissionsToCertificates list,get,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore `
        -PermissionsToKeys decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge `
        -PermissionsToSecrets list,get,set,delete,recover,backup,restore `
		-ServicePrincipalName "49249ac9-68b4-4dc4-b01d-1a6be7278d74"
Set-AzureRmKeyVaultAccessPolicy `
		-VaultName $keyVaultName `
		-ResourceGroupName $ResourceGroupName   `
		-PermissionsToCertificates list,get,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore `
        -PermissionsToKeys decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge `
        -PermissionsToSecrets list,get,set,delete,recover,backup,restore `
		-ServicePrincipalName "25c6921e-e711-4216-bc90-02aac4eb37c2"
Set-AzureRmKeyVaultAccessPolicy `
        -VaultName $keyVaultName -BypassObjectIdValidation -ResourceGroupName $ResourceGroupName `
        -ObjectId $userObjectId  `
        -PermissionsToCertificates list,get,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore `
        -PermissionsToKeys decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge `
        -PermissionsToSecrets list,get,set,delete,recover,backup,restore
   }
else 
{
Write-Output " keyVault already presented"

 $secretName_Exists=(Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name $secretName).Name
  $secretValue_Exists=(Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name $secretName).SecretValueText
       if(!$secretName_Exists)
		      {
			  
		          Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $secretName `
                             -SecretValue  $SecureStringpwd 
	           Write-Output "Secret created successfully"
			   }
	       elseif($secretValue_Exists -ne $secretValue)
	            { 
				 Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $secretName `
                             -SecretValue  $SecureStringpwd 
	                Write-Output "SecretValue updated"

                 }  		      
}

}

else{
Write-Host "There is no Sql Server in the given Resource Group"
}

}

changePassword
