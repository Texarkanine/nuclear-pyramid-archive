var xmlHttp;

function ChkRequestEnc(Encoded)
{
	xmlHttp = GetXmlHttpObject()
	if(xmlHttp==null)
	{
		return false;
	}
	var urlPass = "/check_image.php?enc=" + escape(Encoded);
	urlPass = urlPass + "&rand="+Math.random();
	xmlHttp.onreadystatechange = fillMessage;
	urlPass = new String(urlPass);
	xmlHttp.open("GET",urlPass);
	xmlHttp.send(null);
	return true;
}

function ChkPopunderEnc(Encoded)
{
	xmlHttp = GetXmlHttpObject();
	if(xmlHttp==null)
	{
		return false;
	}
	var urlPass = "/check_popunder.php?enc=" + escape(Encoded);
	urlPass = urlPass + "&rand="+Math.random();
	xmlHttp.onreadystatechange = fillMessage;
	urlPass = new String(urlPass);
	xmlHttp.open("GET",urlPass);
	xmlHttp.send(null);
	return true;
}

function fillMessage()
{
	if(xmlHttp.readyState==4 || xmlHttp.readyState=="complete")
	{
		return true;
	}
}

function GetXmlHttpObject()
{ 
	var objXMLHttp=null;
	if(window.XMLHttpRequest)
	{
		objXMLHttp=new XMLHttpRequest();
	}
	else if(window.ActiveXObject)
	{
		objXMLHttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	return objXMLHttp;
}
