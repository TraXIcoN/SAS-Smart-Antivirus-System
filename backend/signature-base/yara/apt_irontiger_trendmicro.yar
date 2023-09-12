rule IronTiger_ASPXSpy : HIGHVOL
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "ASPXSpy detection. It might be used by other fraudsters"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str2 = "IIS Spy" wide ascii
		$str3 = "protected void DGCoW(object sender,EventArgs e)" wide ascii
	condition:
		any of ($str*)
}

rule IronTiger_ChangePort_Toolkit_driversinstall
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - Changeport Toolkit driverinstall"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "openmydoor" wide ascii
		$str2 = "Install service error" wide ascii
		$str3 = "start remove service" wide ascii
		$str4 = "NdisVersion" wide ascii
	condition:
		uint16(0) == 0x5a4d and (2 of ($str*))
}

rule IronTiger_ChangePort_Toolkit_ChangePortExe
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - Toolkit ChangePort"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "Unable to alloc the adapter!" wide ascii
		$str2 = "Wait for master fuck" wide ascii
		$str3 = "xx.exe <HOST> <PORT>" wide ascii
		$str4 = "chkroot2007" wide ascii
		$str5 = "Door is bind on %s" wide ascii
	condition:
		uint16(0) == 0x5a4d and (2 of ($str*))
}

rule IronTiger_dllshellexc2010
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "dllshellexc2010 Exchange backdoor + remote shell"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "Microsoft.Exchange.Clients.Auth.dll" ascii wide
		$str2 = "Dllshellexc2010" wide ascii
		$str3 = "Users\\ljw\\Documents" wide ascii
		$bla1 = "please input path" wide ascii
		$bla2 = "auth.owa" wide ascii
	condition:
		(uint16(0) == 0x5a4d) and ((any of ($str*)) or (all of ($bla*)))
}

rule IronTiger_dnstunnel
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "This rule detects a dns tunnel tool used in Operation Iron Tiger"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "\\DnsTunClient\\" wide ascii
		$str2 = "\\t-DNSTunnel\\" wide ascii
		$str3 = "xssok.blogspot" wide ascii
		$str4 = "dnstunclient" wide ascii
		$mistake1 = "because of error, can not analysis" wide ascii
		$mistake2 = "can not deal witn the error" wide ascii
		$mistake3 = "the other retun one RST" wide ascii
		$mistake4 = "Coversation produce one error" wide ascii
		$mistake5 = "Program try to use the have deleted the buffer" wide ascii
	condition:
		(uint16(0) == 0x5a4d) and ((any of ($str*)) or (any of ($mistake*)))
}

rule IronTiger_EFH3_encoder
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger EFH3 Encoder"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "EFH3 [HEX] [SRCFILE] [DSTFILE]" wide ascii
		$str2 = "123.EXE 123.EFH" wide ascii
		$str3 = "ENCODER: b[i]: = " wide ascii
	condition:
		uint16(0) == 0x5a4d and (any of ($str*))
}

rule IronTiger_GetPassword_x64
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - GetPassword x64"
		reference = "http://goo.gl/T5fSJC"
		modified = "2023-01-06"
	strings:
		$str1 = "(LUID ERROR)" wide ascii
		$str2 = "Users\\K8team\\Desktop\\GetPassword" wide ascii
		$str3 = "Debug x64\\GetPassword.pdb" ascii
		$bla1 = "Authentication Package:" wide ascii
		$bla2 = "Authentication Domain:" wide ascii
		$bla3 = "* Password:" wide ascii
		$bla4 = "Primary User:" wide ascii
	condition:
		uint16(0) == 0x5a4d and ((any of ($str*)) or (all of ($bla*)))
}

rule IronTiger_GTalk_Trojan
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - GTalk Trojan"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "gtalklite.com" wide ascii
		$str2 = "computer=%s&lanip=%s&uid=%s&os=%s&data=%s" wide ascii
		$str3 = "D13idmAdm" wide ascii
		$str4 = "Error: PeekNamedPipe failed with %i" wide ascii
	condition:
		uint16(0) == 0x5a4d and (2 of ($str*))
}

rule IronTiger_HTTP_SOCKS_Proxy_soexe
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Toolset - HTTP SOCKS Proxy soexe"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "listen SOCKET error." wide ascii
		$str2 = "WSAAsyncSelect SOCKET error." wide ascii
		$str3 = "new SOCKETINFO error!" wide ascii
		$str4 = "Http/1.1 403 Forbidden" wide ascii
		$str5 = "Create SOCKET error." wide ascii
	condition:
		uint16(0) == 0x5a4d and (3 of ($str*))
}

rule IronTiger_NBDDos_Gh0stvariant_dropper
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - NBDDos Gh0stvariant Dropper"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "This service can't be stoped." wide ascii
		$str2 = "Provides support for media palyer" wide ascii
		$str4 = "CreaetProcess Error" wide ascii
		$bla1 = "Kill You" wide ascii
		$bla2 = "%4.2f GB" wide ascii
	condition:
		uint16(0) == 0x5a4d and ((any of ($str*)) or (all of ($bla*)))
}

rule IronTiger_PlugX_DosEmulator
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro - modified by Florian Roth"
		description = "Iron Tiger Malware - PlugX DosEmulator"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "Dos Emluator Ver" wide ascii
		$str2 = "\\PIPE\\FASTDOS" wide ascii
		$str3 = "FastDos.cpp" wide ascii
		$str4 = "fail,error code = %d." wide ascii
	condition:
		uint16(0) == 0x5a4d and 2 of ($str*)
}

rule IronTiger_PlugX_FastProxy
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - PlugX FastProxy"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "SAFEPROXY HTServerTimer Quit!" wide ascii
		$str2 = "Useage: %s pid" wide ascii
		$str3 = "%s PORT[%d] TO PORT[%d] SUCCESS!" wide ascii
		$str4 = "p0: port for listener" wide ascii
		$str5 = "\\users\\whg\\desktop\\plug\\" wide ascii
		$str6 = "[+Y] cwnd : %3d, fligth:" wide ascii
	condition:
		uint16(0) == 0x5a4d and (any of ($str*))
}

rule IronTiger_PlugX_Server
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - PlugX Server"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "\\UnitFrmManagerKeyLog.pas" wide ascii
		$str2 = "\\UnitFrmManagerRegister.pas" wide ascii
		$str3 = "Input Name..." wide ascii
		$str4 = "New Value#" wide ascii
		$str5 = "TThreadRControl.Execute SEH!!!" wide ascii
		$str6 = "\\UnitFrmRControl.pas" wide ascii
		$str7 = "OnSocket(event is error)!" wide ascii
		$str8 = "Make 3F Version Ok!!!" wide ascii
		$str9 = "PELEASE DO NOT CHANGE THE DOCAMENT" wide ascii
		$str10 = "Press [Ok] Continue Run, Press [Cancel] Exit" wide ascii
	condition:
		uint16(0) == 0x5a4d and (2 of ($str*))
}

rule IronTiger_ReadPWD86
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - ReadPWD86"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "Fail To Load LSASRV" wide ascii
		$str2 = "Fail To Search LSASS Data" wide ascii
		$str3 = "User Principal" wide ascii
	condition:
		uint16(0) == 0x5a4d and (all of ($str*))
}

rule IronTiger_Ring_Gh0stvariant
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Malware - Ring Gh0stvariant"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "RING RAT Exception" wide ascii
		$str2 = "(can not update server recently)!" wide ascii
		$str4 = "CreaetProcess Error" wide ascii
		$bla1 = "Sucess!" wide ascii
		$bla2 = "user canceled!" wide ascii
	condition:
		uint16(0) == 0x5a4d and ((any of ($str*)) or (all of ($bla*)))
}

rule IronTiger_wmiexec
{
	meta:
		author = "Cyber Safety Solutions, Trend Micro"
		description = "Iron Tiger Tool - wmi.vbs detection"
		reference = "http://goo.gl/T5fSJC"
	strings:
		$str1 = "Temp Result File , Change it to where you like" wide ascii
		$str2 = "wmiexec" wide ascii
		$str3 = "By. Twi1ight" wide ascii
		$str4 = "[both mode] ,delay TIME to read result" wide ascii
		$str5 = "such as nc.exe or Trojan" wide ascii
		$str6 = "+++shell mode+++" wide ascii
		$str7 = "win2008 fso has no privilege to delete file" wide ascii
	condition:
		2 of ($str*)
}
