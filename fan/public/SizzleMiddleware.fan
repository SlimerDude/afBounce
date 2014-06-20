using afButter
using afSizzle
using xml
using concurrent

** Middleware that lets you make CSS selector queries against the HTTP response.
** 
** You need to make sure the 'ButterResponse' holds a well formed XML document else an 'XErr' is thrown. If rendering
** [Slim]`http://www.fantomfactory.org/pods/afSlim` templates then make sure it compiles XHTML documents (and not HTML):
** 
**   slim := Slim(TagStyle.xhtml) 
** 
** 'SizzleMiddleware' lazily parses the 'ButterResponse' into a 'SizzleDoc' so you can still make requests for non XML
** documents - just don't query them!  
class SizzleMiddleware : ButterMiddleware {
	
	SizzleDoc sizzleDoc {
		get { getSizzleDoc() }
		private set { }
	}

	XElem[] select(Str cssSelector) {
		sizzleDoc.select(cssSelector)
	}

	private Uri?			reqUri
	private SizzleDoc?		doc
	private ButterResponse? res

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		this.res = null
		this.doc = null
		this.reqUri = null
		this.res = butter.sendRequest(req)
		this.reqUri = req.url
		return res
	}

	private SizzleDoc getSizzleDoc() {
		if (res == null)
			throw Err("No requests have been made!")
		if (doc != null)
			return doc
		try {
			doc = SizzleDoc(res.asStr)
			return doc
		} catch (Err e) {
			Env.cur.err.printLine(res.asStr)
			throw ParseErr("Response at `${reqUri}` is NOT XHTML - $e.msg", e)
		}
	}

	private Bool matchesType(MimeType? mimeType, Str[] types) {
		if (mimeType == null)
			return false
		type := "${mimeType.mediaType}/${mimeType.subType}".lower
		return types.any { it == type }
	}
}

