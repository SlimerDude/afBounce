using concurrent
using afSizzle
using afButter
using xml

** (HTML Element) Represents a generic HTML element.
const class Element {
	private const ElemFinder finder
	
	new makeFromCss(Str cssSelector) {
		this.finder = FindFromSizzleThreadLocal(|->SizzleDoc| { sizzleDoc }, cssSelector) 
	}
	
	@NoDoc
	new makeFromFinder(ElemFinder elemFinder) {
		this.finder = elemFinder 
	}

	
	
	// ---- Standard Methods -------------------------------------------------------------------------------------------
	
	** Returns the name of the the element. e.g. 'div'
	** 
	** The method 'name()' is reserved for the 'name' attribute of form inputs.
	Str elementName() {
		findElem.name
	}

	** Returns the 'id' attribute as declared by the element. Returns 'null' if the element does not have an 'id' attribute.
	Str? id() {
		getAttr("id")
	}

	** Returns the 'class' attribute as declared by the element, otherwise 'null'.
	Str? cssClass() {
		getAttr("class")
	}
	@NoDoc @Deprecated { msg="Use 'cssClass()' instead" }
	Str? classs() { cssClass }
	
	** Returns 'true' if the class attribute contains the given value. 
	** 
	** The match is done on a whitespace split of the class attribute and is case insensitive.
	Bool hasCssClass(Str value) {
		getAttr("class")?.lower?.split?.contains(value.trim.lower) ?: false
	}
	@NoDoc @Deprecated { msg="Use 'hasCssClass()' instead" }
	Bool hasClass(Str value) { hasCssClass(value) }
	
	** Returns 'true' if the element defines the given attribute, regardless of its value. 
	Bool hasAttr(Str value) {
		getAttr(value) != null
	}
	
	** Returns 'true' if this element exists.
	Bool exists() {
		!findElems.isEmpty
	}
	
	** Returns the text content of this element and it's child elements.
	Str text() {
		getText(findElem)
	}

	** Returns the markup generated by this node, including the element itself. 
	Str html() {
		getHtml(findElem)
	}

	** Returns the markup generated by the children of this node. 
	Str innerHtml() {
		getInnerHtml(findElem)
	}

	** Returns the value of the named attribute. Returns 'null' if it does not exist.
	** 
	** Example using the operator shortcut:
	** 
	**   attrVal := element["attrName"]
	@Operator
	Str? getAttr(Str name) {
		findElem.attr(name, false)?.val
	}

	** Returns the element of the current selection at the specified index. Use -1 to select from the end of the list.
	** 
	** Example using the operator shortcut:
	** 
	**   value := element[-2]
	** 
	** Note this method is *safe* and does NOT throw an Err should the index be out of bounds. 
	** (Although subsequent method calls on the returned object would fail.)
	** Instead use 'verifyDoesNotExist()'.
	** 
	** Also note that this returns different results to the CSS selector ':nth-child'.  
	@Operator
	This getAtIndex(Int index) {
		newElementAtIndex(index)
	}

	** Returns the number of elements found by the selector
	Int size() {
		findElems.size
	}

	** Finds elements *inside* this element.
	Element find(Str cssSelector) {
		newElementFromCss(cssSelector)		
	}
	
	** Return all elements as a list.
	Element[] list() {
		findElems.map |elem, i| { newElementAtIndex(i) }
	}
	
	** Returns the first 'XElem' object. 
	** 
	** Returns 'null' if 'checked' is 'false' and no elements are found.
	** Always throws an Err is multiple elements are returned.
	XElem? xelem(Bool checked := true) {
		elems := findElems
		if (elems.isEmpty && checked)
			fail("CSS does not exist: ", true)
		if (elems.size > 1)
			fail("CSS returned multiple elements: ", false)
		return elems.first
	}

	** Returns a list of underlying 'XElem' objects. The list may be empty.
	XElem[] xelems() {
		findElems
	}
	
	** Submits an enclosing form to Bed App.
	virtual ButterResponse submitForm() {
		submitEnclosingForm
	}
	

	
	// ---- Verify Methods ---------------------------------------------------------------------------------------------
	
	** Verify that at least one element is selected from the document, otherwise throw a test failure exception.
	Void verifyExists() {
		verifyTrue(exists, "CSS does NOT exist: ")
	}
	
	** Verify that the current selection heralds no elements, otherwise throw a test failure exception.
	Void verifyDoesNotExist() {
		verifyTrue(!exists, "CSS DOES exist: ")
	}
	
	** Verify that the given text matches the text of the element. The match is case insensitive. 
	Void verifyTextEq(Obj expected) {
		verifyEq(text, expected)
	}

	** Verify that the element text contains the given str. The match is case insensitive. 
	Void verifyTextContains(Obj contains) {
		verifyTrue(text.trim.lower.contains(contains.toStr.trim.lower), "Text does NOT contain '${contains}': ")
	}
	
	** Verify that the element has the given attribute value. 
	Void verifyAttrEq(Str attrName, Obj expected) {
		verifyTrue(findElem.attr(attrName, false) != null, "Attribute '${attrName}' does NOT exist: ")
		verifyEq(findElem.attr(attrName).val, expected)
	}
	
	** Verify that the element defines the given attribute, regardless of value. 
	Void verifyAttrExists(Str attrName) {
		verifyTrue(findElem.attr(attrName, false) != null, "Attribute '${attrName}' does NOT exist: ")
	}
	
	** Verify that the current selection has the given size. 
	Void verifySizeEq(Int expectedSize) {
		verifyEq(size.toStr, expectedSize)
	}

	** Verify that the current selection has the given size. 
	Void verifyCssClassContains(Obj expected) {
		attrName := "class"
		verifyTrue(findElem.attr(attrName, false) != null, "Attribute '${attrName}' does NOT exist: ")
		verifyTrue(hasCssClass(expected.toStr), "Class attribute does NOT exist: ")
	}
	@NoDoc @Deprecated { msg="Use 'verifyCssClassContains()' instead" }
	Void verifyClassContains(Obj expected) { verifyCssClassContains(expected) }

	
	
	// ---- Conversion Methods -----------------------------------------------------------------------------------------
	
	** Returns this element as a `CheckBox`
	CheckBox toCheckBox() {
		CheckBox(finder)
	}
	
	** Returns this element as a `Hidden` input
	Hidden toHidden() {
		Hidden(finder)
	}
	
	** Returns this element as a `Link`
	Link toLink() {
		Link(finder)
	}
	
	** Returns this element as an `Option`
	Option toOption() {
		Option(finder)
	}
	
	** Returns this element as a `SelectBox`
	SelectBox toSelectBox() {
		SelectBox(finder)
	}

	** Returns this element as a `SubmitButton`
	SubmitButton toSubmitButton() {
		SubmitButton(finder)
	}

	** Returns this element as a `TextBox`
	TextBox toTextBox() {
		TextBox(finder)
	}

	** Returns this element as a `FormField`
	FormInput toFormInput() {
		FormInput(finder)
	}
	
	
	
	// ---- Common Verify Methods --------------------------------------------------------------------------------------

	@NoDoc
	protected Void verifyTrue(Bool condition, Str msg) {
		testInstance.verify(condition, msg + toStr)
	}
	
	@NoDoc
	protected Void verifyEq(Str actual, Obj expected) {
		if (actual.trim.lower != expected.toStr.trim.lower)
			testInstance.verifyEq(actual.trim, expected.toStr.trim)
	}

	** Returns Obj? so it may be in-lined as a return value
	@NoDoc
	protected Obj? fail(Str msg, Bool showFullPageHtml) {
		if (showFullPageHtml) {
			testInstance.fail(msg + toStr + "\n" + sizzleDoc.rootElement.writeToStr)
		} else
			testInstance.fail(msg + toStr)
		return null
	}
	

	
	// ---- Helper Methods ---------------------------------------------------------------------------------------------

	@NoDoc
	virtual protected XElem findElem() {
		elems := findElems
		if (elems.isEmpty)
			fail("CSS does not exist: ", true)
		if (elems.size > 1)
			fail("CSS returned multiple elements: ", false)
		return elems.first
	}

	@NoDoc
	virtual protected XElem[] findElems() {
		finder.findElems
	}

	@NoDoc
	virtual protected BedClient bedClient() {
		BedClient.getThreadedClient
	}

	@NoDoc
	virtual protected SizzleDoc sizzleDoc() {
		Actor.locals["afBounce.sizzleDoc"] ?: bedClient.sizzleDoc
	}

	private Void processInput(Str:Str values, XElem elem, |Attr attr->Str?| func) {
		attr := Attr(elem)
		// don't submit values of disabled inputs
		if (attr["disabled"] != null)
			return
		val := func.call(attr)
		if (val != null) {
			// only care about the name if we need to submit the value
			name := attr["name"]
			if (name == null)
				Pod.of(this).log.warn("Form element has NO name: " + getHtml(elem))
			else
				values[name] = val
		}
	}
	
	@NoDoc
	virtual protected ButterResponse submitEnclosingForm(XElem? submitElem := null) {
		values	:= [Str:Str][:] { caseInsensitive = true }
		form	:= SizzleDoc(findForm)
		
		form.select("textarea").each |elem| {
			processInput(values, elem) |attr->Str?| {
				return getText(elem)
			}
		}

		form.select("select").each |elem| {
			processInput(values, elem) |attr->Str?| {
				options := SizzleDoc(elem).select("option[selected]")
				return (options.isEmpty) ? null : Attr(options.first)["value"]
			}
		}

		form.select("button").each |elem| {
			processInput(values, elem) |attr->Str?| {
				type := attr["type"]?.trim?.lower
				if (type == "submit" && elem == submitElem)
					return attr["value"]
				return null
			}
		}

		form.select("input").each |elem| {
			processInput(values, elem) |attr->Str?| {
				type := attr["type"]?.trim?.lower ?: "text"
	
				// only the value of the 'clicked' submit button is sent to the server
				if ((type == "submit" || type == "image") && elem != submitElem)
					return null
	
				if (type == "checkbox")
					return (attr["checked"] == null) ? null : "on" 
	
				if (type == "radio")
					return (attr["checked"] == null) ? null : (attr["value"] ?: "") 
	
				return attr["value"] ?: ""
			}
		}
		
		formAttrs   := Attr(form.rootElement) 
		submitAttrs := (submitElem != null) ? Attr(submitElem) : null
		
		action := formAttrs["action"] ?: Str.defVal
		if (action.toStr.isEmpty)
			action = bedClient.lastRequest?.url?.encode ?: Str.defVal
		
		if (submitAttrs?.has("formaction") ?: false)
			action = submitAttrs["formaction"]
		
		if (action.toStr.isEmpty)
			fail("Form has no 'action' attribute: ", false)

		request := ButterRequest(Uri.decode(action))

		method	:= formAttrs["method"]?.trim
		if (submitAttrs?.has("formmethod") ?: false)
			method = submitAttrs["formmethod"]?.trim
		
		encType := formAttrs["formenc"]
		if (submitAttrs?.has("formenctype") ?: false)
			encType = submitAttrs["formenctype"]
		
		if (method != null)
			request.method = method

		// favour setting the enctype rather than not
		if (encType == null && method != "GET")
			encType = "application/x-www-form-urlencoded"
		
		if (encType != null)
			request.headers.contentType = MimeType(encType)
		
		if (request.method == "GET")
			request.url = request.url.plusQuery(values)
		
		else if (request.method == "POST") {
			enc := Uri.encodeQuery(values)
			request.body.print(enc)

		} else {
			// TODO: not sure how to encode non-post stuff
			enc := Uri.encodeQuery(values)
			request.body.print(enc)
		}
		
		return bedClient.sendRequest(request)
	}

	@NoDoc
	virtual protected XElem findForm(XElem elem := findElem) {
		if (elem.name.equalsIgnoreCase("form"))
			return elem
		if (elem.parent != null)
			return findForm(elem.parent)
		return fail("Could not find enclosing Form element", true)
	}
	
	** Sets the attribute. A value of 'null' removes it.
	@NoDoc
	virtual protected Void setAttr(Str name, Str? value, XElem elem := findElem) {
		Attr(elem)[name] = value
	}

	
	
	// ---- Private Methods --------------------------------------------------------------------------------------------

	private This newElementAtIndex(Int index) {
		(Element) typeof.method(#makeFromFinder.name, true).call(finder.clone(FindAtIndex(index)))
	}

	private Element newElementFromCss(Str cssSelector) {
		Element(finder.clone(FindFromCss(cssSelector)))
	}
	
	private Str getHtml(XElem elem) {
		elem.writeToStr
	}

	private Str getInnerHtml(XElem elem) {
		elem.children.map |XNode node->Str| { node.writeToStr }.join
	}

	private Str getText(XNode node) {
		if (node is XText)
			return ((XText) node).val
		if (node is XElem)
			return ((XElem) node).children.map { getText(it) }.join
		return Str.defVal
	}

	private Test testInstance() {
		// a small (external) hook so Test classes can notch up extra verify counts. 
		testInstance := Actor.locals["afBounce.testInstance"]
		return (testInstance != null && testInstance is Test) ? testInstance : Verify()
	}
	
	** Returns the complete CSS selector and the resulting HTML.
	override Str toStr() {
		return finder.toStr + "\n" + findElems.map { getHtml(it) }.join("\n")
	}
}

internal class Attr {
	XElem? elem
	new make(XElem? elem) {
		this.elem = elem
	}
	@Operator
	Str? getAttr(Str name) {
		find(name)?.val
	}
	@Operator
	Void set(Str name, Str? value) {
		attr := find(name)
		if (attr != null)
			elem.removeAttr(attr)
		if (value != null) 
			elem.addAttr(name, value)
	}
	Bool has(Str name) {
		find(name) != null
	}
	Str name() {
		elem.name.trim.lower
	}
	private XAttr? find(Str name) {
		elem.attrs.find { it.name.equalsIgnoreCase(name) }
	}
}

internal class Verify : Test {}


