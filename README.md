# pd-themes-plugin
TCL/TK theme-picker plugin for pure data


This plugin allows you to easily change and manage color themes for Pure Data (Pd). It provides a user-friendly interface to switch between different themes and customize your Pd environment.

## Features

- Easy-to-use theme selection dialog
- Multiple pre-defined themes, including the default "SEM cream" theme
- Ability to apply themes to both existing and new Pd windows
- Option to save custom themes
- Support for setting a default theme
- Dark theme support for macOS

## Installation

1. Clone this repository or download the ZIP file and extract it.
2. Place the entire folder in your Pd externals directory. The default locations are:
   - Windows: `%AppData%\Pd\externals`
   - macOS: `~/Library/Pd`
   - Linux: `~/.pd-externals`
3. Restart Pure Data.

## Usage

### Accessing the Theme Dialog

1. In Pure Data, go to "File" > "Preferences" > "PD Themes..." (on macOS, it's under "Pd" > "Preferences" > "PD Themes...").
2. This will open the Color Themes dialog.

### Selecting a Theme

1. In the Color Themes dialog, you'll see a list of available themes.
2. Hover over a theme to see it highlighted in blue.
3. Click on a theme to select it (it will be highlighted in green).
4. Click the "Apply" button to apply the selected theme.

### Saving a Theme as Default

1. Select and apply the theme you want to set as default.
2. Click the "Save Current" button in the Color Themes dialog.
3. The current theme will now be loaded automatically when you start Pd.

### Creating a New Theme

1. Create a new TCL file in the `themes` folder of the plugin directory.
2. Name it according to the format `yourthemename-theme.tcl`.
3. Define your color scheme in this file. Use the existing theme files as templates.
4. Restart Pd or reopen the Color Themes dialog to see your new theme.

### macOS Dark Theme Support

On macOS, you have additional options:

- "Save as Dark Theme": Sets the current theme as the dark theme for macOS.
- "Delete Dark Theme": Removes the currently set dark theme.

## Default Theme: SEM Cream

The default theme for this plugin is "SEM cream". It provides a warm, easy-on-the-eyes color scheme that enhances readability and reduces eye strain during long Pd sessions.

## Troubleshooting

- If a theme doesn't apply immediately, try closing and reopening your Pd patches.
- Ensure you have write permissions in the plugin directory for saving themes.
- If you encounter any issues, check the Pd console for error messages.

## Contributing

Contributions are welcome! If you've created a great theme or have improvements for the plugin, feel free to submit a pull request.

## License

[Include your chosen license here]

## Acknowledgments

- Thanks to the Pure Data community for inspiration and support.
- Special thanks to [your name or username] for creating and maintaining this plugin.
