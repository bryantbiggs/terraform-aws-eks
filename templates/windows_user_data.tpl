<powershell>
${pre_bootstrap_user_data}
%{ if length(ami_id) > 0 ~}
[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptName = 'Start-EKSBootstrap.ps1'
[string]$EKSBootstrapScriptFile = "$EKSBinDir\$EKSBootstrapScriptName"
& $EKSBootstrapScriptFile -EKSClusterName ${cluster_name} ${bootstrap_extra_args} 3>&1 4>&1 5>&1 6>&1
$LastError = if ($?) { 0 } else { $Error[0].Exception.HResult }
%{ endif ~}
${post_bootstrap_user_data}
</powershell>
