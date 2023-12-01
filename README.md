# Fridge-IO

Welcome to the Fridge App for iOS! This app is designed to help you manage your groceries efficiently, find recipes based on your available ingredients, and organize your shopping lists. Whether you want to keep track of items in your fridge, discover new recipes, or plan your meals, the Fridge App has you covered.

## Table of Contents

- [Getting Started](#getting-started)
- [Features](#features)
- [Run Locally](#run-locally)
- [Usage](#usage)
- [Customisation](#customisation)
- [Contributing](#contributing)
- [API Usage](#api-usage)

## Getting Started

To use the Fridge-IO on your iOS device, follow these steps:

1. Download and install the app from the App Store [here](#https://apps.apple.com/us/app/fridge-io/id6473154554).
2. Launch the app and sign up for a new account or log in if you already have one.
3. Start adding groceries to your virtual fridge and explore the app's features.

## Features

- Grocery Management
    - Add Groceries: Easily add items to your virtual fridge with details such as weight/amount, category, name, and expiry date.
    - Grocery Lists: Create and manage custom grocery lists for organized shopping.
- Recipe Search
    - Find Recipes: Search for recipes based on the ingredients in your fridge.
    - Save Recipes: Save your favorite recipes for later use.
- User Authentication
    - Login and Sign Up: Securely access the app with a personal account.
    - Profile Management: Update your profile information.
- Shopping Lists
    - Create Lists: Build shopping lists based on your groceries or selected recipes.
    - Save Lists: Save your custom shopping lists for future reference.

## Run Locally

To run the Fridge App locally, follow these steps:

1. Clone the repository to your local machine.

```bash
  git clone https://github.com/asianchun/Fridge_IO.git
```

2. Open the directory using Xcode.

3. Run the App on the selected device or simulator.

4. That's it! You're ready to use the Fridge-IO!

## Usage

- User Authentication:
    - Use the "Login" or "Sign Up" page to access your personal account.
    - Update your profile information as needed.

- Add Groceries:
    - Tap the "Add" button to add groceries to your virtual fridge.
    - Input details such as weight/amount, category, name, and expiry date.

- Recipe Search:
    - Explore the "Recipes" section to find new dishes.
    - Save recipes to your profile for quick access.

- Shopping Lists:
    - Create custom shopping lists from your groceries or saved recipes.
    - Save and manage your shopping lists for future use.

## Customisation

Feel free to customize the Fridge App to suit your preferences. Here are a few ideas:

- Recipe Recommendations: Implement an algorithm for personalized recipe recommendations.
- UI Themes: Offer different themes for the app's user interface.

## Contributing

If you have any suggestions, improvements, or bug fixes, feel free to open an issue or create a pull request. Your contributions are highly welcome!

## API Usage

#### External API

The Fridge App utilizes an external API to enhance its functionality. Here are the details about the API:

- **Name:** Edamam Recipe API
- **Description:** The API retrieves a list of recipes based on the query
- **Documentation:** https://developer.edamam.com/edamam-recipe-api
- **API Key:** You can retrieve the API keys by signing up and following the instructions there

### How to Integrate the API

1. Obtain an API key.
2. In the Fridge-IO App, navigate to the RecipePageTableViewController and update the "app_id" and "app_key" with your API key inside the "requestRecipes" funtion.
