// *******************************************************************
// $DateTime: 2012/01/24 03:51:25 $
// $Revision: #1 $
// *******************************************************************


/* =================================================================== */
/*                                                                     */
/* FUNCTIONS FOR XML BASED CONTENT                                     */
/*                                                                     */
/* =================================================================== */

/*
  FUNCTION SAPXDPFEEDBACK
    graphicRef = URI to the graphic
    tt_Feedback = Text for the QuickInfo
    Feedback = Link text
    MailAddress = EMail address for the feedback mail
    LOIO = LOIO and further information on the info object
*/
function sapxdpfeedback(graphicRef, tt_Feedback, Feedback, MailAddress, LOIO) {
  if (MailAddress != '[NO FEEDBACK MAIL ADDRESS AVAILABLE]') {
    document.write(
                   '<img'
                   + ' alt="' + tt_Feedback + '"'
                   + ' src="' + graphicRef + '"'
                   + ' \/>'
                   + '<a'
                   + ' href="mailto:' + MailAddress + '?subject=SAP%20Library%20Feedback&amp;body=Hello,%0D%0A%0D%0A%0D%0A************%0D%0A' + LOIO + '%0D%0A%3C' + document.location.href + '%3E%0D%0A************%0D%0A"'
                   + ' title="' + tt_Feedback + '"'
                   + '>'
                   + Feedback
                   + '<\/a>');
  }
}


/*
  FUNCTION SAPXDPPRINTPREVIEW
    graphicRef = URI to the graphic
    tt_PrintPreview = Text for the QuickInfo
    PrintPreview = Link text
*/
function sapxdpprintpreview(graphicRef, tt_PrintPreview, PrintPreview) {
  document.write(
                 '<img'
                 + ' alt="' + tt_PrintPreview + '"'
                 + ' src="' + graphicRef + '"'
                 + ' \/>'
                 + '<a'
                 + ' target="_blank"'
                 + ' href="' + document.location.href + '"'
                 + ' title="' + tt_PrintPreview + '"'
                 + '>'
                 + PrintPreview
                 + '<\/a>');
}


/* DOESN'T WORK FOR IE 7 */
function addBookMark_IE() {
  var href = document.location.href;
  var tit = document.title;
  try {
    window.external.addfavorite(href, tit);
  }
  catch(e) {
    var msg = "";
    msg += "Your security settings prevent bookmarking. Copy the URL below into your browser address bar, access it, and use the browser button to bookmark it.";
    prompt(msg, href);
  }
}
/*
  FUNCTION SAPXDPADDBOOKMARK
    graphicRef = URI to the graphic
    tt_Bookmark = Text for the QuickInfo
    Bookmark = Link text
*/
function sapxdpaddbookmark(graphicRef, tt_Bookmark, Bookmark) {
  if ((navigator.appName == 'Microsoft Internet Explorer' || navigator.appName == 'Netscape') && (location.protocol == 'http:' || location.protocol == 'https:')) //http(s) only; doesn't work for file protocol
  {
    document.write('<img alt="' + tt_Bookmark + '" src="' + graphicRef + '" \/><a');
    if (navigator.appName == 'Microsoft Internet Explorer') {
        document.write(' href="javascript:addBookMark_IE()"');
    }
    if (navigator.appName == 'Netscape') {
      document.write(' href="javascript:window.sidebar.addPanel(document.title, document.location.href, \'\');"');
    }
    document.write(' title="' + tt_Bookmark + '" rel="bookmark">' + Bookmark + '<\/a>');
  }
}

/*
  FUNCTION SYNC
    loio = LOIO of the info object
*/
function Sync(loio) {
  var loops = 10;
  if (top.SAP_TOC && top.SAP_TOC.gMenu) {
    top.SAP_TOC.gMenu.SelectEntry(loio);
  }
  else if (top != self && loops-- > 0) {
    window.setTimeout( "Sync('" + loio + "')", 500 );
  }
}

/* =================================================================== */
/*                                                                     */
/* FUNCTIONS FOR WORD BASED CONTENT                                    */
/*                                                                     */
/* =================================================================== */

function iwbfeedback(IMAGE_PATH, TT_FEEDBACK, FEEDBACK, MAIL, LOIO)
{
  document.write(
                 '<img'
                 + ' alt="' + TT_FEEDBACK + '"'
                 + ' src="' + IMAGE_PATH + '/feedback.gif"'
                 + ' \/>'
                 + '<a'
                 + ' href="mailto:' + MAIL + '?subject=SAP%20Library%20Feedback&amp;body=Hello,%0D%0A%0D%0A%0D%0A************%0D%0A' + LOIO + '%0D%0A%3C' + document.location.href + '%3E%0D%0A************%0D%0A"'
                 + ' title="' + TT_FEEDBACK + '"'
                 + '>'
                 + FEEDBACK
                 + '<\/a>');
}


function iwbprintpreview(IMAGE_PATH, TT_PRINTPREVIEW, PRINTPREVIEW)
{
  document.write(
                 '<img'
                 + ' alt="' + TT_PRINTPREVIEW + '"'
                 + ' src="' + IMAGE_PATH + '/printpreview.gif"'
                 + ' \/>'
                 + '<a'
                 + ' target="_blank"'
                 + ' href="' + document.location.href + '"'
                 + ' title="' + TT_PRINTPREVIEW + '"'
                 + '>'
                 + PRINTPREVIEW
                 + '<\/a>');
}


function iwbaddbookmark(IMAGE_PATH, TT_BOOKMARK, BOOKMARK)
{
  if ((navigator.appName == 'Microsoft Internet Explorer' || navigator.appName == 'Netscape') && (location.protocol == 'http:' || location.protocol == 'https:')) //http(s) only; doesn't work for file protocol
  {
    document.write('<img alt="' + TT_BOOKMARK + '" src="' + IMAGE_PATH + '/bookmark.gif" \/><a');
    if (navigator.appName == 'Microsoft Internet Explorer')
    {
        document.write(' href="javascript:addBookMark_IE()"');
    }
    if (navigator.appName == 'Netscape')
    {
      document.write(' href="javascript:window.sidebar.addPanel(document.title, document.location.href, \'\');"');
    }
    document.write(' title="' + TT_BOOKMARK + '" rel="bookmark">' + BOOKMARK + '<\/a>');
  }

}
