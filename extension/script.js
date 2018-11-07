safari.self.addEventListener("message", function (event) {
    if (event.name == "credentials") {
        alert("Hi, I'm the first safari app extension, This is a message received from safari app extension." + JSON.stringify(event.message));
    } else {
        console.log("Received a message named: " + event.name);
    }
});
