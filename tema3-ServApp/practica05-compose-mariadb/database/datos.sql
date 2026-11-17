-- datos.sql - Practica 05 (Jose Manuel Sanz - JMS)
SET NAMES utf8mb4;
USE practica05JMS;

INSERT INTO tareas (titulo, descripcion, estado) VALUES
('Instalar Docker Compose', 'Instalar el plugin de Docker Compose en la instancia EC2.', 'completada'),
('Crear la base de datos', 'Diseñar el esquema de practica05JMS y la tabla tareas.', 'completada'),
('Conectar Flask con MariaDB', 'Leer las tareas desde la aplicación Flask con PyMySQL.', 'en_progreso'),
('Configurar Nginx', 'Reverse Proxy con HTTPS hacia el servicio Flask.', 'en_progreso'),
('Comprobar la persistencia', 'Apagar y encender los contenedores sin perder datos.', 'pendiente'),
('Realizar una copia de seguridad', 'Generar backup.sql con mariadb-dump.', 'pendiente'),
('Restaurar los datos', 'Simular una pérdida de datos y restaurar desde backup.sql.', 'pendiente');


