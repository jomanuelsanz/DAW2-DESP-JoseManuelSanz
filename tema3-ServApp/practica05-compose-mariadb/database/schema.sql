-- schema.sql - Practica 05 (Jose Manuel Sanz - JMS)
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS practica05JMS
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE practica05JMS;

CREATE TABLE IF NOT EXISTS tareas (
    id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    titulo         VARCHAR(100) NOT NULL,
    descripcion    TEXT NULL,
    estado         ENUM('pendiente','en_progreso','completada') NOT NULL DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;




