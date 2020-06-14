<?

$from = "email@domain.name";
$to = "box@mydomain.com";
$cc= "ccbox@mydomain.com";
$bcc = "bccbox@mydomain.com";

$header = "From: " . $from . "\r\n".
$header = "Reply-To: " . $from . "\r\n".
	  "Content-Type: text/plain; charset=utf-8;\r\n".
          # we don't need MID here cause wrapper generate it 
          #"Message-ID: <" . time() . "." . $from . ">\r\n".
	  "Cc: " . $cc . "\r\n".
          "Bcc: " . $bcc;

# use it with mail() function  
#$param = "-f" . $from;

$subject = "The subject";
$body = "Hello,\n\nThis is the mail body";

if (mail($to, $subject, $body, $header, $param)) {
echo("<p>Message successfully sent!</p>");
} else {
echo("<p>Message delivery failed...</p>");
}

?>
