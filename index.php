<?php
/*
 *      index.php
 * 		Website plugins.geany.org
 *
 *      (C) Copyright 2009 by Dominic Hopf <dmaphy@googlemail.com>
 * 		(C) Copyright 2010 by Michael Spahn <m.spahn@any0n3.de>
 *      Version: 1.0.0
 *      Last Change: 2010-7-24
 */

define('CONTENTPATH','./content/');

if (isset($_GET['site']))
{
	if (file_exists(CONTENTPATH . $_GET['site'] . '.html'))
	{
		define('CONTENTFILE', CONTENTPATH . $_GET['site'] . '.html');
	}

	else
	{
		define('CONTENTFILE', CONTENTPATH . '404.html');
	}
}

else
{
	define('CONTENTFILE', CONTENTPATH . 'start.html');
}

print '<?xml version="1.0"?>';
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">

<head>
	<title>Plugins for Geany</title>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="./stylesheets/mainstyle.css" />
</head>
<body>
	<a href="https://github.com/geany/geany-plugins">
		<img style="position: fixed; top: 0; left: 0; border: 0;"
			src="./images/ForkMe_Blk.png" alt="Fork me on GitHub"></a>

	<div id="header">
		<a href="./">
		<img src="./images/geany.png" alt="Geany Logo"
			style="width: 48px; height: 48px; float: left; margin-left: 2%; margin-right: 5%;" /></a>
		<h1>Plugins for Geany</h1>
	</div>

	<div id="navigation">
		<h1>Geany Plugins project</h1>
		<ul>
			<?php
			include_once './content/geany-plugins-listing.html';
			?>
		</ul>

		<hr />

		<h1>Other Third-Party plugins</h1>
		<ul>
			<li><a href="externdbg.html">externdbg</a></li>
			<li><a href="geanyembrace.html">geanyembrace</a></li>
			<li><a href="geany-mini-script.html">Geany Mini Script</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="downloads.html">Downloads</a></li>
			<li><a href="install.html">Installation</a></li>

		</ul>

		<hr />


		<ul>
			<li><a href="https://sourceforge.net/tracker/?group_id=222729&amp;atid=1056532">Bugtracker</a></li>
			<li><a href="https://sourceforge.net/tracker/?group_id=222729&amp;atid=1056535">Feature Requests</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="licensing.html">Licensing</a></li>
			<li><a href="about.html">About</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="http://geany.org/">Geany</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="README.html">List or update a plugin</a></li>
		</ul>
	</div>

		<div id="content">
		<?php include_once CONTENTFILE; ?>
	</div>

	<div id="footer">
		<p>
			<a href="http://sourceforge.net/projects/geany-plugins">
				<img src="http://sflogo.sourceforge.net/sflogo.php?group_id=222729&amp;type=16"
					width="150" height="40" alt="Get geany-plugins at SourceForge.net.
					Fast, secure and Free Open Source software downloads" /></a>

			<a href="https://github.com/geany/geany-plugins"
				title="Geany-Plugins is on GitHub"
				style="padding-left: 100px;">
			<img src="./images/github.png"
				style="width: 91px; height: 40px;" alt="GitHub Logo" /></a>
		</p>

		<p>&copy; Dominic Hopf &amp; Michael Spahn <br />
		Contact <a href="http://dominichopf.de/">Dominic Hopf</a> or the
		<a href="http://www.geany.org/Support/MailingList">Geany Team</a>
		for questions.</p>
	</div>
</body>
</html>
