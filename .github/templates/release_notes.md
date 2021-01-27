<h1>New Shortcuts</h1>

With this update Pass for macOS unifies the shortcuts and changes the auto-fill behaviour.

<b><i>Note: This update breaks compatibility with macOS version older than 10.14.4 (Mojave).</i></b>

<h2>Using the shortcut outside of Safari</h2>
By using the default shortcut `shift-ctrl-p` (or the user-defined shortcut from the preferences), a popover will be shown containing a search field. Here, you can search for passwords. Selecting a search result by double-click or with enter will copy the password to the clipboard, exactly as `pass -c <password>` does.

<h2>Using the shortcut in Safari</h2>
When you use the shortcut within Safari, Pass for macOS will search a password containing the current domain.
If only one matching password was found, Pass for macOS will auto-fill the credentials and notify you with a little notification in the top right corner.
If more than one matching password was found, the popover in the toolbar will show and you can manually select the correct password (which will be used for auto-fill) or refine the search.
