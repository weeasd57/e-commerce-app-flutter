# e-commerce-app-flutter

## Application Overview

A comprehensive e-commerce application built with Flutter to deliver a seamless and engaging shopping experience across various platforms (Android, iOS, Web). The application follows the latest clean design and architectural practices to ensure easy customization, maintenance, and high performance.

## Key Features

*   **User Authentication System:**
    *   Email and password login and registration.
    *   Google Sign-In integration.
    *   Password reset functionality.
    *   Secure user session management.
*   **Product & Category Management:**
    *   Display of diverse products and their categorization.
    *   Showcase of sale products and new arrivals.
    *   Dedicated pages for product categories.
*   **Shopping Cart:**
    *   Add products to cart and update quantities.
    *   Remove products from cart.
    *   Display of total price.
    *   Checkout page with shipping details.
*   **Wishlist:**
    *   Add and remove products from the wishlist.
*   **Order Management:**
    *   System for managing orders (expandable to include order tracking).
*   **Localization & Multi-language Support:**
    *   Full support for English and Arabic with easy language switching.
    *   Standard ARB files for easy addition of more languages.
*   **Theming & Color Management:**
    *   Light and Dark Mode support.
    *   Selection of various primary solid colors.
    *   Selection of attractive gradient colors for the user interface.
*   **Responsive Design:**
    *   Design that automatically adapts to different screen sizes (phones, tablets, web).
*   **Page Transitions & Animations:**
    *   Smooth and appealing page transitions using `SlideTransition` to enhance user experience.
*   **State Management:**
    *   Utilizes Provider for efficient state management, ensuring high performance and minimizing re-renders.
*   **Performance & Security:**
    *   Robust practices to prevent Memory Leaks through proper management of Controllers, Stream Subscriptions, and network resources.
    *   Secure management of Firebase connections.
    *   Uses `SharedPreferences` for secure local storage of non-sensitive data.
*   **Dynamic Currency Code:**
    *   Fetches currency code (e.g., SAR) from Firebase Firestore, allowing currency updates from the dashboard without app updates.

## Technologies Used

*   **Flutter SDK:** Latest version for frontend development.
*   **Firebase:**
    *   **Firebase Authentication:** For user management.
    *   **Cloud Firestore:** For storing and managing data (products, categories, orders, app settings).
    *   **Firebase Storage:** For storing product images and media.
*   **Provider:** For state management.
*   **Shared Preferences:** For lightweight local data storage.
*   **http / Dio:** (If used) For making HTTP requests.
*   **intl / flutter_localizations:** For internationalization and multi-language support.
*   **carousel_slider:** For displaying promotional sliders.
*   **cached_network_image:** For optimized network image loading and display.
*   **url_launcher:** For opening external links.
*   **flutter_rating_bar:** For displaying product ratings.
*   **uuid:** For generating unique identifiers.
*   **path_provider:** For accessing device file paths.
*   **image_picker:** (If used) For picking images.

## Architectural Structure & Clean Code

*   **Modular Design:** Code is organized into logical units (providers, models, pages, widgets, utils).
*   **SOLID & DRY Principles:** Application of clean coding principles to ensure scalability and maintainability.
*   **Provider Usage:** Providers are logically placed within the widget tree to minimize re-builds and ensure optimal performance.
*   **Descriptive Comments:** Sufficient comments in the code to explain logic and functionalities.

## Ready for Sale

This application is ready for sale on platforms like CodeCanyon, offering:
*   Clean, organized, and easily understandable and modifiable code.
*   Internal documentation (Comments) to assist developers in understanding the codebase.
*   Comprehensive features for a modern e-commerce application.
*   Support for localization and customization (Theming).
*   High performance with memory leak prevention.