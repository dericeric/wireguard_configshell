#V1.0��maytom2016������2022-02-12

function GetServer([REF]$spri,[REF]$spub)
{
#�ж�server�ļ����Ƿ����
$Fexist=Test-Path .\server
if(! $Fexist)
{
New-item -path .\ -name server -type directory
}

$Fexist=Test-Path .\server\sprivatekey
#�ж�server�����Ƿ����
 if(! $Fexist)
 {
  wg genkey | tee sprivatekey | wg pubkey > spublickey
  #�ƶ��ļ������ļ�����
  Move-Item .\sprivatekey .\server\sprivatekey
  Move-Item .\spublickey .\server\spublickey
   #���server��Կ
  $spri.Value = Get-Content .\server\sprivatekey
  $spub.Value = Get-Content .\server\spublickey
 }
 else
 {
  $spri.Value = Get-Content .\server\sprivatekey
  $spub.Value = Get-Content .\server\spublickey
 }
}

#����wg0�����ļ�
function MakeServerConfig()
{
  $pri=1
  $pub=1
  GetServer ([REF]$pri) ([REF]$pub)
#�ж�configĿ¼�Ƿ����
 $Fexist=Test-Path .\config
 if(! $Fexist)
 {
  New-item -path .\ -name config -type directory
 }

 $Fexist=Test-Path .\config\wg0.conf
 if(! $Fexist)
 {
   $ifa ="[Interface]"
   $prk ="PrivateKey = "+ $pri
   $lsp ="ListenPort = 23456"
   $add ="Address = 192.168.100.1/24"
   $rn="`r`n"
   $serfile=$ifa+$rn+$prk+$rn+$lsp+$rn+$add+$rn
   Set-Content -Path .\config\wg0.conf -Value ($serfile)
 }
 else
 {
  echo "wg0�����ļ�����!�����ظ�����"
 }
}
function RetServerConfig
{

   $Fexist=Test-Path .\config\wg0.conf
   if($Fexist)
   {
     Remove-Item .\config\wg0.conf
   }
   MakeServerConfig
}


function GetClient($num,[REF]$cpri,[REF]$cpub,[REF]$csh)
{
#�ж�client�ļ����Ƿ����
$Fexist=Test-Path .\client
if(! $Fexist)
{
New-item -path .\ -name client -type directory
}
$Fexist=Test-Path (".\client\cprivatekey"+$num)
#�ж�client�����Ƿ����
 if(! $Fexist)
 {
  wg genkey | tee (".\cprivatekey"+$num) | wg pubkey > (".\cpublickey"+$num)
  wg genpsk > (".\sharekey"+$num)
  #�ƶ��ļ������ļ�����
  Move-Item (".\cprivatekey"+$num) (".\client\cprivatekey"+$num)
  Move-Item (".\cpublickey"+$num) (".\client\cpublickey"+$num)
  Move-Item (".\sharekey"+$num) (".\client\sharekey"+$num)
  #���client��Կ
  $cpri.Value = Get-Content (".\client\cprivatekey"+$num)
  $cpub.Value = Get-Content (".\client\cpublickey"+$num)
  $csh.Value=Get-Content(".\client\sharekey"+$num)
 }
 else
 {
  #���client��Կ
  echo (".\client\cprivatekey"+$num+"�ļ�����")
  $cpri.Value = Get-Content (".\client\cprivatekey"+$num)
  $cpub.Value = Get-Content (".\client\cpublickey"+$num)
  $csh.Value=Get-Content(".\client\sharekey"+$num)
 }
}

function AddClientConfig ($clientnum)
{
   $spri=1
   $spub=1
   GetServer ([REF]$spri) ([REF]$spub)
   RetServerConfig
  for($x=1; $x -lt ($clientnum+1); $x=$x+1)   
  { 
    $cpri=1
    $cpub=1
    $csh=1
    GetClient $x ([REF]$cpri) ([REF]$cpub) ([REF]$csh)
    
    if (1){ 
    $per="[Peer]"
    $cpub="PublicKey = " +$cpub
    $csh="PresharedKey = "+$csh
    $alip="AllowedIPs = 192.168.100." + ($x +1)+"/32"
    $rn="`r`n"
    $clientfile=$per+$rn+$cpub+$rn+$csh+$rn+$alip+$rn
    add-content .\config\wg0.conf -value $clientfile
    }
    MakeClientConfig $x $cpri $csh $spub
  }
}

function MakeClientConfig ($clientnum,$cpri,$csh,$spub)
{
   $ipconf = Get-Content .\ipport.conf
   $a= 1..10
   $cfile=""
   $rn="`r`n"
   $a[0] ="[Interface]"+$rn
   $a[1] ="Address = 192.168.100."+($clientnum+1)+"/32"+$rn
   $a[2] ="PrivateKey = "+ $cpri+$rn
   $a[3] ="DNS = 114.114.114.114"+$rn
   $a[4] ="[Peer]"+$rn
   $a[5] ="PublicKey = "+ $spub+$rn
   $a[6] = $csh+$rn
   $a[7] ="AllowedIPs = 192.168.100.0/24"+$rn
   $a[8] ="Endpoint ="+$ipconf+$rn
   $a[9] ="PersistentKeepalive = 25"+$rn

   for($x=0; $x -lt 11; $x=$x+1) 
   {
     $cfile=$cfile+$a[$x]
     
   }
   Set-Content -Path (".\config\c" + $clientnum + ".conf") -Value ($cfile)
}

#��������ͻ���
AddClientConfig 3