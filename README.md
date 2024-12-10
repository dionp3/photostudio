# Photo Studio API

This is a API for a Photo Studio application built with **Express.js** and **PostgreSQL**.

---

## **Photo Studio API Documentation**

### **Base URL**
```
http://localhost:{PORT}
```

---

## **Public Endpoints**

### **GET /**  
**Description:**  
Homepage API.  
**Response:**  
- 200 OK  

```json
{
  "message": "Welcome to the Photo Studio API Project by Dion Prayoga"
}
```

---

## **Authentication Endpoints**

### **POST /auth/register**  
**Description:**  
Register a new user.  
**Request Body:**  

```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```

**Response:**  
- 201 Created  

---

### **POST /auth/registerAdmin**  
**Description:**  
Register a new admin (requires admin authorization).  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```

**Response:**  
- 201 Created  

---

### **POST /auth/login**  
**Description:**  
User login.  
**Request Body:**  

```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**  
- 200 OK  

---

### **POST /auth/logout**  
**Description:**  
Logout current user.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **GET /auth/profile**  
**Description:**  
Get user profile (requires authentication).  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **PUT /auth/editProfile**  
**Description:**  
Edit user profile.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```

**Response:**  
- 200 OK  

---

### **DELETE /auth/delete**  
**Description:**  
Delete user account.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **POST /auth/requestForgotPW**  
**Description:**  
Request password reset link.  
**Request Body:**  

```json
{
  "email": "string"
}
```

**Response:**  
- 200 OK  

---

### **POST /auth/forgotPW**  
**Description:**  
Reset password using the provided token.  
**Request Body:**  

```json
{
  "token": "string",
  "newPassword": "string"
}
```

**Response:**  
- 200 OK  

---

## **User Endpoints**

### **GET /user/dashboard**  
**Description:**  
Access the user dashboard.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **GET /user/studios**  
**Description:**  
Get the list of available studios.  
**Response:**  
- 200 OK  

---

### **GET /user/equipments**  
**Description:**  
Get the list of available equipment.  
**Response:**  
- 200 OK  

---

### **GET /user/photographers**  
**Description:**  
Get the list of available photographers.  
**Response:**  
- 200 OK  

---

### **GET /user/allReservations**  
**Description:**  
Get all reservations.  
**Response:**  
- 200 OK  

---

### **GET /user/studioReservations**  
**Description:**  
Get user-specific studio reservations.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **POST /user/studioPayment**  
**Description:**  
Process payment for studio reservations.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "reservation_id": "string",
  "payment_amount": "string"
}
```

**Response:**  
- 200 OK  

---

### **POST /user/reserveStudio**  
**Description:**  
Create a new studio reservation.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "studio_id": "string",
  "start_time": "datetime",
  "end_time": "datetime"
}
```

**Response:**  
- 201 Created  

---

### **POST /user/rentEquipment**  
**Description:**  
Rent equipment.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "equipment_id": "int",
  "rental_start": "datetime",
  "rental_end": "datetime",
  "quantity": "int"
}
```

**Response:**  
- 201 Created  

---

## **Admin Endpoints**

### **GET /admin/dashboard**  
**Description:**  
Access the admin dashboard.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **POST /admin/studio**  
**Description:**  
Add a new studio.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "studioName": "string",
  "studioCapacity": "int",
  "studioLocation": "string",
  "studioHourlyRate": "int"
}
```

**Response:**  
- 201 Created  

---

### **PUT /admin/studio**  
**Description:**  
Update studio information.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "studioId": "string",
  "newStudioName": "string",
  "newStudioCapacity": "int",
  "newStudioLocation": "string",
  "newStudioHourlyRate": "int"
}
```

**Response:**  
- 200 OK  

---

### **DELETE /admin/studio**  
**Description:**  
Delete a studio.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "studioId": "string"
}
```

**Response:**  
- 200 OK  

---



### **POST /admin/equipment**  
**Description:**  
Add new equipment.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "name": "string",
  "quantity": "int",
  "description": "string"
}
```

**Response:**  
- 201 Created  

---

### **PUT /admin/equipment**  
**Description:**  
Update equipment details.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "equipment_id": "string",
  "name": "string",
  "quantity": "int",
  "description": "string"
}
```

**Response:**  
- 200 OK  

---

### **DELETE /admin/equipment**  
**Description:**  
Delete equipment.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "equipment_id": "int"
}
```

**Response:**  
- 200 OK  

---

### **GET /admin/photographers**  
**Description:**  
Get all photographers.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

---

### **POST /admin/photographer**  
**Description:**  
Add a new photographer.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "name": "string",
  "experience": "string",
  "rate": "int"
}
```

**Response:**  
- 201 Created  

---

### **PUT /admin/photographer**  
**Description:**  
Update photographer details.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "photographerId": "string",
  "name": "string",
  "experience": "string",
  "rate": "int"
}
```

**Response:**  
- 200 OK  

---

### **DELETE /admin/photographer**  
**Description:**  
Delete a photographer.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Request Body:**  

```json
{
  "photographerId": "string"
}
```

**Response:**  
- 200 OK  

---

### **GET /admin/reservations**  
**Description:**  
Get all reservations for admin.  
**Request Headers:**  
- `Authorization: Bearer <token>`  

**Response:**  
- 200 OK  

```json
[
  {
    "reservationId": "string",
    "user": "string",
    "studio": "string",
    "date": "YYYY-MM-DD",
    "timeSlot": "string",
    "status": "string"
  }
]
```

---

## **Error Handling**

All endpoints return the following format for errors:  

**Response Body:**  

```json
{
  "error": "Error message"
}
```

**Status Codes:**  
- 400 Bad Request  
- 401 Unauthorized  
- 403 Forbidden  
- 404 Not Found  
- 500 Internal Server Error  

---

## **Authorization Middleware**

### **Authentication (authenticate)**  
- Required for endpoints that need user login.  
- Include a valid JWT token in the `Authorization` header.  

### **Authorization (authorizeAdmin)**  
- Required for admin-only endpoints.  
- Checks if the logged-in user has admin privileges.  

---

## **Notes**

- Replace `{PORT}` in the Base URL with the port number defined in your `.env` file or the default port `3000`.  
- Ensure you have a valid JWT token to access protected routes.  
- For `POST`, `PUT`, and `DELETE` requests, include the required fields in the request body as JSON.  
