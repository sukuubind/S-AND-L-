/* Common Section*/
.headerSection {
	width: 600px;
	height: 75px;
	background-color: #ffffff;
	color: white;
}

.headerLogo {
	margin-top: 15px;
	margin-left: 20px;
}

.headerChatBubbles {
	float: right;
	margin-top: 15px;
	margin-right: 20px;
}

.titleSection {
	color: #ffffff;
	font-family: Avenir Next;
	font-weight: bold;
	font-size: 18px;
	width: 100%;
	padding-top: 20px;
}

.subtitleSection {
	color: #ffffff;
	font-family: Avenir Next;
	font-size: 16px;
	padding-bottom: 20px;
}

.errorMessagesSection {
	font-family: Avenir Next;
	font-size: 16px;
	color: red;
	padding-bottom: 20px;
}

.inputSection {
	width: 280px;
	height: 20px;
	font-family: Avenir Next;
	font-size: 14px;
	margin-top: 10px;
	margin-bottom: 10px;
}

.buttonSection {
	width: 160px !important;
	border-radius: 5px !important;
	color: #555555 !important;
	background-color: #ffde00 !important;
	background-image: none !important;
	font-family: Avenir Next !important;
	font-size: 140% !important;
	font-weight: bold !important;
	text-transform: uppercase !important;
	padding-top: 10px !important;
	padding-bottom: 10px !important;
	margin-top: 10px !important;
	margin-bottom: 10px !important;
	cursor: pointer !important;
}

.tdFormSection {
	width: 350px;
}

.tdImgSection {
	width: 190px;
}

.footerSection {
	width: 600px;
	height: 50px;
	background: rgb(181,189,200); /* Old browsers */
	background: -moz-linear-gradient(top,  rgba(181,189,200,1) 0%, rgba(111,104,98,1) 96%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(181,189,200,1)), color-stop(96%,rgba(111,104,98,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  rgba(181,189,200,1) 0%,rgba(111,104,98,1) 96%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  rgba(181,189,200,1) 0%,rgba(111,104,98,1) 96%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  rgba(181,189,200,1) 0%,rgba(111,104,98,1) 96%); /* IE10+ */
	background: linear-gradient(to bottom,  rgba(181,189,200,1) 0%,rgba(111,104,98,1) 96%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#b5bdc8', endColorstr='#6f6862',GradientType=0 ); /* IE6-9 */

}



/* PreChat Section */

.prechatForm {
	width: 550px;
	min-height: 355px;
	padding-left: 35px;
	padding-right: 15px;
	background-color: #005581;
}

.preChatInsetImgSection {
        padding-top: 29px;
	padding-left: 40px;
	padding-bottom: 15px;
}



/* Chat Section */

.chatSection {
	width: 600px;
	height: 400px;
	overflow: hidden;
	background: #005581;
}

#liveAgentClientChat.liveAgentStateWaiting .msgSection {
	display: none;
}

.msgSection {
	margin-top: 5px;
	margin-left: 5px;
	padding-left: 15px;
	font-family: Avenir Next;
	font-size: 16px;
	width: 400px;
	color: #ffffff;
}

.liveAgentEndButton { 
	width: 100px !important;
	height: 30px !important;
	margin-top: 6px;
	margin-right: -7px;
	background: #ffde00 !important;
	color: #555555 !important;
	font-family: Avenir Next !important;
	font-size: 120% !important;
	font-weight: bold !important;
	text-transform: uppercase !important;
	cursor: pointer !important;
}

#liveAgentChatLog {
	border: 1px solid #ffffff !important;
	width: 570px !important;
	height: 300px !important;
	position: absolute !important;
	overflow-y: auto !important;
	top: 125px !important;
	left: 7px !important;
	word-wrap: break-word !important;
	background: #ffffff !important;
	font-size: 14px !important;
	padding: 5px !important;
}

#liveAgentChatLogText .operator .name {
	color: #005581;
}

#liveAgentChatLogText .client .name {
	color: #ffde00;
}

.liveAgentChatInput { 
	width: 500px !important;
	border: 1px solid #ffffff !important;
	background: #ffffff !important;
	position: absolute !important;
	top: 440px !important;
	left: 7px !important;
}

.liveAgentSendButton {
	width: 60px !important;
	position: absolute !important;
	top: 442px !important;
	left: 529px !important;
	background: #ffde00 !important;
	color: #555555 !important;
	font-family: Avenir Next !important;
	font-size: 140% !important;
	font-weight: bold !important;
	text-transform: uppercase !important;
	cursor: pointer !important;
}

#waitingMessage { 
	height: 100%; 
	width: 100%; 
	vertical-align: middle; 
	text-align: center;
	display: none; 
	color: #ffffff;
}

#liveAgentClientChat.liveAgentStateWaiting #waitingMessage { 
	display: table; 
	margin-top: 30%;
	font-family: Avenir Next;
	font-size: 16px;
	color: #ffffff;
}

.waitingMessageSection {
	font-family: Avenir Next;
	font-size: 16px;
	color: #ffffff;
}

.progressBarSection {
	margin-top: 10px;
}



/* PostChat Section */

.postchatForm {
	width: 550px;
	padding-left: 35px;
	padding-right: 15px;
	background-color: #005581;
}

.messagesSection {
	font-family: Avenir Next;
	font-size: 16px;
	padding-top: 20px;
	color: #ffffff;
}

.questionSection {
	font-family: Avenir Next;
	font-size: 14px;
	font-weight: bold;
	color: #ffffff;
}

.postChatInsetImgSection {
	padding-top: 15px;
	padding-left: 20px;
	padding-bottom: 15px;
}