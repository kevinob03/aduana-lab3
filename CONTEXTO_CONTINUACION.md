# Contexto para continuar el Laboratorio #3

## Objetivo del proyecto

Este repositorio contiene el trabajo del **Laboratorio #3: Sistema de inventario para una aduana**, de la materia Bases de Datos. Se ha trabajado con MySQL como gestor y se sigue un orden por fases.

## Estado al 26 de octubre de 2026

| Fase | Estado | Archivo principal |
|---|---|---|
| 1. Investigación | Terminada | `investigacion_fase1.md` |
| 2. Diseño del DER | Terminada | `fase2_diseno_der.md` |
| 3. Tablas y datos | Terminada | `Aduana_Lab3.sql` |
| 4. Consultas | Terminada | `Aduana_Lab3.sql` y `fase4_consultas_explicadas.md` |
| 5. Agente en n8n | Preparada, falta prueba real | `Agente_Aduana_n8n.json` y `fase5_agente_n8n.md` |

El archivo `checklist_progreso.md` tiene el detalle de cada fase y debe actualizarse antes de hacer cambios importantes.

## Archivos importantes

- `Aduana_Lab3.sql`: crea la base `aduana_lab3`, sus 13 tablas, datos de prueba y ocho consultas analíticas.
- `fase2_diseno_der.md`: guía para dibujar manualmente el Diagrama Entidad-Relación; no se generó una imagen digital automática.
- `Agente_Aduana_n8n.json`: plantilla de flujo para importar en n8n. No contiene claves ni contraseñas.
- `usuario_mysql_solo_lectura.sql`: crea el usuario `agente_aduana_lectura` con permiso exclusivo de `SELECT`.
- `fase5_agente_n8n.md`: pasos de configuración y ocho preguntas que deben probarse en el agente.

## Pendiente principal: terminar las pruebas reales de n8n

En la computadora actual, n8n no estaba instalado ni había credenciales de OpenAI o MySQL configuradas. Por eso **no se deben inventar capturas ni afirmar que el agente fue probado**.

Para terminar:

1. Instalar o abrir n8n (nube, `npx n8n` o Docker).
2. Ejecutar `Aduana_Lab3.sql` en MySQL 8.0 o superior.
3. Editar y ejecutar `usuario_mysql_solo_lectura.sql` con una contraseña real y privada.
4. Importar `Agente_Aduana_n8n.json` en n8n.
5. Crear las credenciales de OpenAI y MySQL dentro de n8n; nunca subirlas al repositorio.
6. Hacer las ocho pruebas de `fase5_agente_n8n.md` y tomar una captura de cada respuesta.
7. Exportar el flujo desde n8n y revisar que no incluya secretos.
8. Actualizar `checklist_progreso.md`: marcar la Fase 5 como terminada solo después de estas pruebas.

## Recomendaciones de seguridad

- No subir archivos `.env`, contraseñas, claves API ni exportaciones de credenciales.
- El agente debe conectarse con `agente_aduana_lectura`, no con `root`.
- El usuario del agente solo debe tener permiso `SELECT` sobre `aduana_lab3`.

## Cómo retomar el trabajo con Codex

Abrir esta carpeta en Codex y escribir algo como:

> Lee `CONTEXTO_CONTINUACION.md` y `checklist_progreso.md`. Quiero continuar con las pruebas reales de la Fase 5 del Laboratorio 3 sin modificar las fases ya terminadas.

