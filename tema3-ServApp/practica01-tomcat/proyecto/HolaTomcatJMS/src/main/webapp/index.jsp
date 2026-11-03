<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>HolaTomcatJMS</title>
</head>
<body>
    <h1>¡Hola Tomcat! Soy José Manuel Sanz (JMS)</h1>
    <p>Práctica 1 - DAW2 - Despliegue de Aplicaciones Web</p>
    <p>Servidor: <%= application.getServerInfo() %></p>
    <p>Versión de Java: <%= System.getProperty("java.version") %></p>
    <p>Fecha y hora del servidor: <%= new java.util.Date() %></p>
</body>
</html>