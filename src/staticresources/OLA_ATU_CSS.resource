/* HEADER AREA */

/* Main Header Image */
/* Image size should be no larger than 950px wide and 232px tall */

body .container .header {	
    background: url("/resource/1482856217000/OLA_ATU_Header") top left no-repeat; background-size:contain;background-size:100%;
}

/* Mobile Header Image */
/* Image size should be no larger than 950px wide and 232px tall */

body .container .header_phone {
    background: url("/resource/1482856217000/OLA_ATU_Header") top left no-repeat;background-size:contain;background-size:100%;
}

/* Main Header Title Text */

body .container .header h1 {
    background-color: #FFFFFF;
    color: #192954;
}

/* Login/Register Link */

body .container .header #accountLinks li a:link, body .container .header #accountLinks li a:visited,
body .container .header_phone #accountLinks li a:link, body .container .header_phone #accountLinks li a:visited {
    color: #567bb9;
}

/* Login/Register Link - Hover */

body .container .header #accountLinks li a:link:hover, body .container .header #accountLinks li a:visited:hover,
body .container .header_phone #accountLinks li a:link:hover,body .container .header_phone #accountLinks li a:visited:hover {
    color: #1b5590;
    text-decoration: underline;
}

/* Login/Register Pipe Color */

body .container .header #accountLinks li:first-child,
body .container .header_phone #accountLinks li:first-child {
    border-right: 1px solid #1b5590;
}

/* BODY CONTENT AREA */

/* Main Body Text/Site Background Color */

body {
    color: #8a8a8a;
	background-color:#EBEBEB;
}

/* Paragraph Text */

body p {
    color: #8a8a8a;
}

/* Main Section Title Text */

body .container .existing_applicants h2 {
    border-bottom: 1px solid #b2cfe4;
    color: #21578e;
}

/* General Text Link */

a {
    color: #567bb9;
    text-decoration: underline;
}

/* General Text Link - Hover */

a:hover,
a:focus {
    color: #1b5590;
    text-decoration: underline;
}

/* Filled In Text Display */

body .container .existing_applicants dl dd {
    color: #21578E;
}

/* Button Off State */

.btn {
    background-color: #1b5590;
    color: #FFFFFF;
}

/* Button On State */

.btn:hover,
.btn:focus {
    color: #FFF;
    background-color: #567BB9;
}

/* Mini-Button */

body .container .btn-mini {
    background: none repeat scroll 0 0 #1B5590;   
}

/* Progress Percentage Bar */

.progress-striped .bar {
    background-color: #1b5590;
}

/* Progress Slider Navigation Current Step */

body #progressSlider .scroll-pane .scroll-content .scroll-content-item.current a {
    background: none repeat scroll 0 0 #1b5590;
    color: #FFFFFF;
}

/* FOOTER AREA */

/* Footer Text */

body .container .footer p {
    color: #ffffff;
}

/* Footer Links */

body .container .footer p a:link, body .container .footer p a:visited {
    color: #94b7e1;
    text-decoration: underline;
}

/* Footer Links - Hover */

body .container .footer p a:hover{
	text-decoration:underline;
}

/* Footer Background/Image Properties */
/* Image size should be no larger than 950px wide and 48px tall */

body .container .footer {
    background: url("/resource/1482856329000/OLA_ATU_Footer") no-repeat scroll right center #1a5590;
}

/* MOBILE AREA */

/* Main Page Title */

body .container h1.phone {
    color: #21578E;
}

/* Collapsible Menu Title */

.navbar .brand {
    color: #21578e;
    text-shadow: 0 1px 0 #FFFFFF;
}

/* Collapsible Menu Dropdown Button */

body .container .navbar .btn-navbar {
    background-color: #21578e;
}

/* Collapsible Menu Dropdown Button - Hover */

body .container .navbar .btn-navbar:hover,body .container .navbar .btn-navbar:focus,body .container .navbar .btn-navbar:active,body .container .navbar .btn-navbar.active,body .container .navbar .btn-navbar.disabled,body .container .navbar .btn-navbar[disabled]{
	color:#fff;
	background-color:#1b5590;
	background-image:none;
}

/* Collapsible Menu Navigation */

body .container .nav-collapse .nav > li > a, body .container .nav-collapse .dropdown-menu a {
    color: #666666;
}

/* Collapsible Menu Navigation - Hover */

.nav-collapse .nav > li > a:hover,
.nav-collapse .nav > li > a:focus,
.nav-collapse .dropdown-menu a:hover,
.nav-collapse .dropdown-menu a:focus {
   background-color: #f2f2f2;
}

/* Collapsible Menu Main Step Navigation */

body .container .nav-collapse li.visible-phone a {
    background: none repeat scroll 0 0 #21578e;
    color: #FFFFFF;
    display: inline-block;
}

/* Collapsible Menu Main Step Navigation - Hover */

body .container .nav-collapse li.visible-phone a:hover {
	background:#567BB9;
	color:#FFFFFF;
}