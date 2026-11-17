/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: practica05JMS
-- ------------------------------------------------------
-- Server version	11.4.13-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Current Database: `practica05JMS`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `practica05JMS` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `practica05JMS`;

--
-- Table structure for table `tareas`
--

DROP TABLE IF EXISTS `tareas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tareas` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('pendiente','en_progreso','completada') NOT NULL DEFAULT 'pendiente',
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tareas`
--

LOCK TABLES `tareas` WRITE;
/*!40000 ALTER TABLE `tareas` DISABLE KEYS */;
INSERT INTO `tareas` VALUES
(1,'Instalar Docker Compose','Instalar el plugin de Docker Compose en la instancia EC2.','completada','2026-11-17 15:04:13'),
(2,'Crear la base de datos','Diseñar el esquema de practica05JMS y la tabla tareas.','completada','2026-11-17 15:04:13'),
(3,'Conectar Flask con MariaDB','Leer las tareas desde la aplicación Flask con PyMySQL.','en_progreso','2026-11-17 15:04:13'),
(4,'Configurar Nginx','Reverse Proxy con HTTPS hacia el servicio Flask.','en_progreso','2026-11-17 15:04:13'),
(5,'Comprobar la persistencia','Apagar y encender los contenedores sin perder datos.','pendiente','2026-11-17 15:04:13'),
(6,'Realizar una copia de seguridad','Generar backup.sql con mariadb-dump.','pendiente','2026-11-17 15:04:13'),
(7,'Restaurar los datos','Simular una pérdida de datos y restaurar desde backup.sql.','pendiente','2026-11-17 15:04:13'),
(8,'Tarea nueva 1 - JMS','Insertada a mano para probar la persistencia','pendiente','2026-11-17 15:12:55'),
(9,'Tarea nueva 2 - JMS','Segunda tarea insertada desde MariaDB','en_progreso','2026-11-17 15:12:55'),
(10,'Tarea nueva 3 - JMS','Tercera tarea para la prueba de persistencia','pendiente','2026-11-17 15:12:55');
/*!40000 ALTER TABLE `tareas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-17 16:18:37
