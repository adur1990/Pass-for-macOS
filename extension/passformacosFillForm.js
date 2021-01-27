//Copyright 2018 Artur Sterz
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

safari.self.addEventListener("message", function (event) {
    if (event.name == "credentials") {
        if (event.message.shortcut) {
            if (event.message.login) {
                toast("Filling password for ".concat(window.top.location.hostname));
            } else {
                if (event.message.message == "Pass for macOS is not running.") {
                    toast(event.message.message)
                } else {
                    toast("No matching password found for ".concat(window.top.location.hostname));
                }
            }
        }
    passformacosFillForm(event.message.password, event.message.login);
    } else {
        console.log("Received a message named: " + event.name);
    }
});

window.onload = function() {
    if (window.top != window.self) {
        return
    }
    
    var toastContainer = document.createElement("div");
    toastContainer.setAttribute("id", "toast");
    document.body.appendChild(toastContainer);
}

window.toast = function(message) {
    if (window.top != window.self) {
        return
    }
    
    var _toastContainer = document.getElementById("toast");
    _toastContainer.innerHTML = message;
    _toastContainer.className = "show";
    
    setTimeout(
               function(){
                _toastContainer.className = _toastContainer.className.replace("show", "");
               },
               2000);
}

window.passformacosFillForm = function (p, u) {
    const FORM_MARKERS = [
        "login",
        "log-in",
        "log_in",
        "signin",
        "sign-in",
        "sign_in"
    ];
    const USERNAME_FIELDS = {
        selectors: [
            "input[id*=openid i]",
            "input[name*=openid i]",
            "input[class*=openid i]",
            "input[id*=user i]",
            "input[name*=user i]",
            "input[class*=user i]",
            "input[id*=login i]",
            "input[name*=login i]",
            "input[class*=login i]",
            "input[id*=email i]",
            "input[name*=email i]",
            "input[class*=email i]",
            "input[type=email i]",
            "input[type=text i]",
            "input[type=tel i]"
        ],
        types: ["email", "text", "tel"]
    };
    const PASSWORD_FIELDS = {
        selectors: ["input[type=password i]"]
    };
    const INPUT_FIELDS = {
        selectors: PASSWORD_FIELDS.selectors.concat(USERNAME_FIELDS.selectors)
    };
    const SUBMIT_FIELDS = {
        selectors: [
            "[type=submit i]",
            "button[name*=login i]",
            "button[name*=log-in i]",
            "button[name*=log_in i]",
            "button[name*=signin i]",
            "button[name*=sign-in i]",
            "button[name*=sign_in i]",
            "button[id*=login i]",
            "button[id*=log-in i]",
            "button[id*=log_in i]",
            "button[id*=signin i]",
            "button[id*=sign-in i]",
            "button[id*=sign_in i]",
            "button[class*=login i]",
            "button[class*=log-in i]",
            "button[class*=log_in i]",
            "button[class*=signin i]",
            "button[class*=sign-in i]",
            "button[class*=sign_in i]",
            "input[type=button i][name*=login i]",
            "input[type=button i][name*=log-in i]",
            "input[type=button i][name*=log_in i]",
            "input[type=button i][name*=signin i]",
            "input[type=button i][name*=sign-in i]",
            "input[type=button i][name*=sign_in i]",
            "input[type=button i][id*=login i]",
            "input[type=button i][id*=log-in i]",
            "input[type=button i][id*=log_in i]",
            "input[type=button i][id*=signin i]",
            "input[type=button i][id*=sign-in i]",
            "input[type=button i][id*=sign_in i]",
            "input[type=button i][class*=login i]",
            "input[type=button i][class*=log-in i]",
            "input[type=button i][class*=log_in i]",
            "input[type=button i][class*=signin i]",
            "input[type=button i][class*=sign-in i]",
            "input[type=button i][class*=sign_in i]"
        ]
    };

    function queryAllVisible(parent, field, form) {
        var result = [];
        for (var i = 0; i < field.selectors.length; i++) {
            var elems = parent.querySelectorAll(field.selectors[i]);
            for (var j = 0; j < elems.length; j++) {
                var elem = elems[j];
                // Select only elements from specified form
                if (form && form != elem.form) {
                    continue;
                }
                // Ignore disabled fields
                if (elem.disabled) {
                    continue;
                }
                // Elem or its parent has a style 'display: none',
                // or it is just too narrow to be a real field (a trap for spammers?).
                if (elem.offsetWidth < 30 || elem.offsetHeight < 10) {
                    continue;
                }
                // We may have a whitelist of acceptable field types. If so, skip elements of a different type.
                if (field.types && field.types.indexOf(elem.type.toLowerCase()) < 0) {
                    continue;
                }
                // Elem takes space on the screen, but it or its parent is hidden with a visibility style.
                var style = window.getComputedStyle(elem);
                if (style.visibility == "hidden") {
                    continue;
                }
                // Elem is outside of the boundaries of the visible viewport.
                var rect = elem.getBoundingClientRect();
                if (
                    rect.x + rect.width < 0 ||
                    rect.y + rect.height < 0 ||
                    (rect.x > window.innerWidth || rect.y > window.innerHeight)
                ) {
                    continue;
                }
                // This element is visible, will use it.
                result.push(elem);
            }
        }
        return result;
    }

    function queryFirstVisible(parent, field, form) {
        var elems = queryAllVisible(parent, field, form);
        return elems.length > 0 ? elems[0] : undefined;
    }

    function form() {
        var elems = queryAllVisible(document, INPUT_FIELDS, undefined);
        var forms = [];
        for (var i = 0; i < elems.length; i++) {
            var form = elems[i].form;
            if (form && forms.indexOf(form) < 0) {
                forms.push(form);
            }
        }
        if (forms.length == 0) {
            return undefined;
        }
        if (forms.length == 1) {
            return forms[0];
        }

        // If there are multiple forms, try to detect which one is a login form
        var formProps = [];
        for (var i = 0; i < forms.length; i++) {
            var form = forms[i];
            var props = [form.id, form.name, form.className];
            formProps.push(props);
            for (var j = 0; j < FORM_MARKERS.length; j++) {
                var marker = FORM_MARKERS[j];
                for (var k = 0; k < props.length; k++) {
                    var prop = props[k];
                    if (prop.toLowerCase().indexOf(marker) > -1) {
                        return form;
                    }
                }
            }
        }

        console.error(
            "Unable to detect which of the multiple available forms is the login form. Please submit an issue for browserpass on github, and provide the following list in the details: " +
            JSON.stringify(formProps)
        );
        return forms[0];
    }

    function find(field, form) {
        return queryFirstVisible(document, field, form);
    }

    function update(field, value, form) {
        if (!value.length) {
            return false;
        }

        // Focus the input element first
        var el = find(field, form);
        if (!el) {
            return false;
        }
        var eventNames = ["click", "focus"];
        eventNames.forEach(function (eventName) {
            el.dispatchEvent(new Event(eventName, { bubbles: true }));
        });

        // Focus may have triggered unvealing a true input, find it again
        el = find(field, form);
        if (!el) {
            return false;
        }

        // Now set the value and unfocus
        el.setAttribute("value", value);
        el.value = value;
        var eventNames = [
            "keypress",
            "keydown",
            "keyup",
            "input",
            "blur",
            "change"
        ];
        eventNames.forEach(function (eventName) {
            el.dispatchEvent(new Event(eventName, { bubbles: true }));
        });
        return true;
    }

    var loginForm = form();

    update(USERNAME_FIELDS, u, loginForm);
    update(PASSWORD_FIELDS, p, loginForm);

    var password_inputs = queryAllVisible(document, PASSWORD_FIELDS, loginForm);
    if (password_inputs.length > 1) {
        // There is likely a field asking for OTP code, so do not submit form just yet
        password_inputs[1].select();
    } else {
        window.requestAnimationFrame(function () {
            // Try to submit the form, or focus on the submit button (based on user settings)
            var submit = find(SUBMIT_FIELDS, loginForm);
            if (submit) {
                submit.focus();
            } else {
               var password = find(PASSWORD_FIELDS, loginForm);
                if (password) {
                    password.focus();
                } else {
                    var username = find(USERNAME_FIELDS, loginForm);
                    if (username) {
                        username.focus();
                    }
                }
            }
        });
    }
};
