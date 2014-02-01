using xml
using afButter

** (HTML Element) Represents a form '<input>' of type 'submit'.
const class Button : Element {
	
	@NoDoc
	new makeFromFinder	(ElemFinder elemFinder)	: super(elemFinder)  { }
	new makeFromCss		(Str cssSelector) 		: super(cssSelector) { }

	** Returns the 'name' attribute.
	Str? name() {
		getAttr("name")
	}

	** Gets and sets the 'value' attribute.
	Str value {
		get { getAttr("value") }
		set { 
			elem := findElem
			if (isButton(elem)) {
				elem.children.each { elem.remove(it) }
				elem.add(XText(it))
				return
			}
			setAttr("value", it) 
		}
	}

	** Gets and sets the 'disabled' attribute (inverted).
	Bool enabled {
		get { getAttr("disabled") == null }
		set { setAttr("disabled", it ? null : "disabled") }
	}

	** Gets and sets the 'disabled' attribute.
	Bool disabled {
		get { getAttr("disabled") != null }
		set { setAttr("disabled", it ? "disabled" : null) }
	}
	
	** Submits the enclosing form, complete with this button's value.
	ButterResponse click() {
		submitForm
	}

	** Submits the enclosing form, complete with this button's value.
	ButterResponse submitForm() {
		super.submitEnclosingForm(findElem)
	}
	
	@NoDoc
	override protected XElem findElem() {
		elem := super.findElem
		if (!isButton(elem) && !isSubmit(elem))
			return fail("Element is NEITHER a button nor a submit input: ", false)
		return elem
	}

	private Bool isButton(XElem elem := findElem) {
		elem.name.equalsIgnoreCase("button")
	}
	
	private Bool isSubmit(XElem elem) {
		(Attr(elem).name == "input") && (Attr(elem)["type"]?.lower == "submit") 
	}
}