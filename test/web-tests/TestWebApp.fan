
internal class TestWebApp : WebTest {
	
	Void testBedApp() {
		// when
		client.get(`/index`)
		
		// then
		title := Element("#title")
		title.verifyTextEq("Sizzle Kicks Ass!")
	}	

	Void testWebSession() {
		client.get(`/index`)
		verifyNull(client.webSession)
		
		verifyEq(client.get(`/session`).body.str, "count 1")
		verifyNotNull(client.webSession)
		
		verifyEq(client.get(`/session`).body.str, "count 2")
		verifyEq(client.get(`/session`).body.str, "count 3")
		
		client = server.makeClient
		verifyEq(client.get(`/session`).body.str, "count 1")
	}	
}

