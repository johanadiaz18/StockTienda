# StockTienda

## Descripción del proyecto

StockTienda es una aplicación móvil desarrollada para facilitar la gestión y el control de inventario en pequeños comercios, como kioscos y tiendas de ropa.

Permite registrar productos, organizar categorías, controlar las entradas y salidas de mercadería y consultar información sobre el estado del stock.

La aplicación utiliza una base de datos local, por lo que permite trabajar sin necesidad de conexión a Internet.

## Problemática

En muchos comercios pequeños, el control del inventario se realiza manualmente mediante cuadernos, planillas o anotadores. Esto puede generar dificultades para controlar el stock, identificar productos que necesitan reposición y evitar errores en los registros.

StockTienda busca ofrecer una herramienta sencilla que permita organizar esta información y facilitar las tareas diarias del comercio.

## Objetivo

Desarrollar una aplicación móvil que permita administrar productos y controlar el inventario de pequeños comercios de manera simple, organizada y eficiente.

## Funcionalidades principales

- Configuración inicial del comercio.
- Registro y administración de categorías.
- Registro y edición de productos.
- Carga de fotografías de productos.
- Registro de entradas y salidas de mercadería.
- Actualización automática del stock.
- Alertas de productos con stock bajo.
- Consulta de reportes e información del inventario.
- Modificación de los datos del comercio.

## Tecnologías utilizadas

- **Flutter:** framework utilizado para desarrollar la aplicación.
- **Dart:** lenguaje de programación.
- **SQLite:** sistema de base de datos local.
- **sqflite:** paquete que permite conectar Flutter con SQLite.
- **Visual Studio Code:** entorno de desarrollo utilizado.

## Requisitos

Para abrir y ejecutar el proyecto se necesita:

- Flutter instalado.
- Dart.
- Visual Studio Code.
- Un dispositivo Android o emulador para realizar las pruebas.

## Instalación y ejecución

1. Descargar o copiar la carpeta del proyecto.
2. Abrir la carpeta `stocktienda` desde Visual Studio Code.
3. Abrir la terminal y ejecutar:

```bash
flutter pub get
```

4. Conectar un dispositivo Android o iniciar un emulador.
5. Ejecutar la aplicación con:

```bash
flutter run
```

## Estructura del proyecto

```text
stocktienda/
├── android/
├── assets/
│   └── images/
├── lib/
│   ├── database/
│   ├── models/
│   ├── screens/
│   ├── services/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## Pruebas realizadas

La aplicación fue probada en los siguientes dispositivos:

- Samsung Galaxy A33 5G (SM-A336M), con Android 16.
- ZTE Blade A54.

También se realizaron pruebas de las principales funcionalidades para comprobar el correcto funcionamiento de la aplicación.

## Generación del APK

Para generar el instalador de Android se utilizó el siguiente comando:

```bash
flutter build apk --release
```

El archivo APK generado se encuentra en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Almacenamiento de datos

La aplicación utiliza SQLite para almacenar localmente la información del comercio, las categorías, los productos y los movimientos de stock.

Los datos permanecen guardados en el dispositivo y no se sincronizan automáticamente con otros dispositivos.

## Estado del proyecto

Proyecto desarrollado y probado. Las principales funcionalidades fueron verificadas en dispositivos Android.