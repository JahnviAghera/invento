# Invento - Inventory Management System

## Introduction
Invento is an inventory management system designed to help businesses efficiently manage their stock, generate invoices, and track inventory in real time. The app offers QR-based store access, barcode scanning, low-stock alerts, billing, and analytics, making inventory management seamless and scalable.

## App Flow and Navigation

### Authentication Flow
1. **Login Screen:** Users can log in using Email/Password or Google Sign-In.
2. **Registration Screen:** New users can create an account.
3. **Auth Wrapper:** Determines whether the user is logged in:
    - If logged in, redirects to User Selection Screen.
    - If not logged in, stays on Login Screen.

### User Selection Flow
1. **User Selection Screen:**
    - Create a New Store → Redirects to Create Store Screen.
    - Access an Existing Store → Redirects to Staff Access Screen.

### Store Setup and Access Flow
1. **Create Store Screen:**
    - Users enter a store name.
    - Store is created in Firebase, and a QR code is generated.
    - Redirects to Store QR Code Screen.
2. **Store QR Code Screen:**
    - Displays QR code for store identification.
    - Users can save or share the QR code.
3. **Staff Access Screen:**
    - Users enter the store's QR code manually or scan it.
    - Store ID is saved locally for auto-login.
    - Redirects to Inventory Dashboard.

### Inventory Management Flow
1. **Inventory Dashboard:**
    - Displays stock overview.
    - Users can search products, see low-stock alerts, and manage inventory.
2. **Add Product Screen:**
    - Users scan a barcode or enter product details manually.
    - Product is saved in Firebase.
3. **Edit Product Screen:**
    - Users can update product name, SKU, stock, price, and cost.
4. **Search and View Products:**
    - Users can search for products and view details.

### Billing and Data Export
1. **Billing Screen:**
    - Users scan products or select them manually to create an invoice.
    - Generates a PDF bill and allows sharing.
2. **Export Data Screen:**
    - Users can export inventory data in Excel or PDF format.
3. **Insights and Reports:**
    - Users can view inventory analytics and generate reports.

## Features
✅ **User Authentication:** Secure login via Email/Password and Google Sign-In.
✅ **Store Creation & QR Access:** Easily create and manage multiple stores.
✅ **Inventory Management:** Add, edit, delete, and search products.
✅ **Barcode Scanning:** Scan product barcodes for quick tracking.
✅ **Low Stock Alerts:** Get notified when inventory runs low.
✅ **Billing System:** Generate invoices and share PDF receipts.
✅ **Data Export:** Export inventory data to Excel/PDF.
✅ **Analytics & Reporting:** View inventory insights and generate reports.

## Technology Stack

### Frontend
- **Flutter** - Cross-platform UI framework.
- **Dart** - Optimized for mobile performance.
- **Material Design** - Modern UI for smooth UX.

### Backend & Database
- **Firebase Authentication** - Secure user login.
- **Firebase Firestore** - Real-time inventory tracking.
- **Firebase Storage** - Storing images, QR codes, and invoices.

### Additional Libraries & Services
- **QR Code & Barcode Scanner** - Enables seamless inventory tracking.
- **Shared Preferences** - Stores user and store session data locally.
- **Image & File Handling** (`path_provider`, `share_plus`, `pdf`, `excel`) - Supports data export and invoice generation.
- **Google Sign-In** - Simplifies authentication.
- **Analytics & Reporting** - Firebase analytics for business insights.

## Competitive Advantages
### 1. Innovative Features
Invento integrates QR-based store access, real-time stock management, automated billing, and barcode scanning, making it a modern and scalable solution.

### 2. Scalability & Real-Time Updates
Using Firebase Firestore, we ensure instant updates across all users without requiring manual refreshes. This enhances efficiency and eliminates stock mismanagement.

### 3. User-Centric Design
The app follows Material Design principles, ensuring a smooth and intuitive experience. Employees and store owners can navigate the system without extensive training.

### 4. Security & Authentication
With Firebase Authentication and role-based access control, Invento ensures only authorized users can access and modify stored data.

### 5. Future Expansion Possibilities
- AI-powered demand forecasting to optimize inventory levels.
- Automated order restocking alerts to improve efficiency.
- Integration with Google Cloud Vision for text-based scanning.

## User Guide
### Getting Started
1. **Sign Up / Login:**
    - Open the app and log in with your Email/Password or Google.
    - If new, register and create an account.
2. **Store Setup:**
    - If you own a store, create a new store and generate a QR code.
    - If you are a staff member, scan the store QR code to gain access.
3. **Managing Inventory:**
    - Use the dashboard to add, update, or search products.
    - Scan product barcodes for easy tracking.
    - Get alerts for low-stock items.
4. **Billing & Exporting Data:**
    - Scan items to create an invoice and generate a bill.
    - Export inventory data as an Excel or PDF file.

### Best Practices
✔ Keep your QR code secure for store access.
✔ Regularly update stock levels to avoid discrepancies.
✔ Use barcode scanning for faster product identification.
✔ Generate reports periodically for better inventory insights.

## Why Invento Should Be Selected?
✅ **Problem-Solving:** Addresses real-world inventory tracking & store management issues.
✅ **Scalability:** Supports multiple stores, users, and real-time updates.
✅ **Security:** Uses Firebase for authentication, data protection, and cloud backup.
✅ **Technology-driven:** Uses Flutter & Firebase, ensuring speed and reliability.
✅ **Future-Proof:** The foundation allows easy AI integration for analytics & automation.

By selecting Invento, you are choosing a powerful, modern, and scalable inventory management solution that leverages the latest technologies while prioritizing usability, security, and business efficiency. 🚀🔥

## Demo & Source Code
🎥 **Demo Video:**
[Watch the Demo](https://www.youtube.com/watch?v=1E5ne-VZulw)

💻 **Source Code:**
[GitHub Repository](https://github.com/JahnviAghera/invento)
