<?php
/*
 *	index.php
 *	Website plugins.geany.org
 *
 *	(C) Copyright 2009 by Dominic Hopf <dmaphy@googlemail.com>
 *	(C) Copyright 2010 by Michael Spahn <m.spahn@any0n3.de>
 *	Version: 1.0.0
 *	Last Change: 2010-7-24
 */

define('CONTENTPATH','./content/');

if (isset($_GET['site']))
{
	if (file_exists(CONTENTPATH . $_GET['site'] . '.html'))
	{
		define('CONTENTFILE', CONTENTPATH . $_GET['site'] . '.html');
		define('PAGETITLE', $_GET['site']);
	}

	else
	{
		define('CONTENTFILE', CONTENTPATH . '404.html');
		define('PAGETITLE', 'Plugin could not be found.');
	}
}

else
{
	define('CONTENTFILE', CONTENTPATH . 'start.html');
	define('PAGETITLE', '');
}

print '<?xml version="1.0"?>';
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">

<head>
	<title>Plugins for Geany [<?php print PAGETITLE ?>]</title>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="./stylesheets/mainstyle.css" />
</head>
<body>
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

		<h1>Third-Party plugins</h1>
		<ul>
			<li><a href="djynn.html">Djynn</a></li>
			<li><a href="https://sourceforge.net/projects/geanyeasyunicodeinput/">GeanyEasyUnicodeInput</a></li>
			<li><a href="https://sourceforge.net/projects/geanyunicodetocodepoint/">GeanyUnicodeToCodepoint</a></li>
			<li><a href="https://sourceforge.net/projects/geanyhighlightselectedword/">GeanyHighlightSelectedWord</a></li>
			<li><a href="jsonprettifier.html">JSON Prettifier Plugin</a></li>
			<li><a href="quick_open_file.html">Geany Quick Open File Plugin</a></li>
			<li><a href="togglebars.html">Togglebars</a></li>
			<li><a href="pynav.html">pynav</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="downloads.html">Downloads</a></li>
			<li><a href="install.html">Installation</a></li>

		</ul>

		<hr />


		<ul>
			<li><a href="https://github.com/geany/geany-plugins/issues">Tracker</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="licensing.html">Licensing</a></li>
			<li><a href="about.html">About</a></li>
		</ul>

		<hr />

		<ul>
			<li><a href="https://geany.org/">Geany</a></li>
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
			<a href="https://github.com/geany/geany-plugins"
				title="Geany-Plugins is on GitHub"
				style="padding-left: 100px;">
			<img src="./images/github.png"
				style="width: 91px; height: 40px;" alt="GitHub Logo" /></a>
		</p>

		<p> Contact the <a
		href="https://www.geany.org/support/mailing-lists/">Geany Team</a> for
		questions.</p>
	</div>
</body>
</html>
