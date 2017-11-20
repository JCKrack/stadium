-- Sql
USE [master];
GO 
CREATE DATABASE [seatOrganizer];
GO
USE [seatOrganizer];
GO

CREATE SCHEMA [ventas];
GO
CREATE SCHEMA [admin];
GO
CREATE SCHEMA [catalogo];
GO

CREATE TABLE [catalogo].[areas_ctg](
	id CHAR(3) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	color CHAR(7) NOT NULL,
	CONSTRAINT PK_AreasCtg PRIMARY KEY (id)
);
CREATE TABLE [catalogo].[secciones_ctg](
	id CHAR(2) NOT NULL,
	area CHAR(3) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	CONSTRAINT PK_SeccionesCtg PRIMARY KEY (id, area),
	CONSTRAINT FK_AreasCtg FOREIGN KEY(area) REFERENCES [catalogo].[areas_ctg](id)
);
CREATE TABLE [admin].[eventos](
	id INT NOT NULL IDENTITY(1,1),
	nombre VARCHAR(20) NOT NULL,
	fecha DATETIME NOT NULL,
	descripcion VARCHAR(120) NOT NULL,
	CONSTRAINT PK_Eventos PRIMARY KEY(id),
	CONSTRAINT CHK_Eventos_fecha CHECK(fecha = GETDATE())
);
CREATE TABLE [admin].[precios](
	evento INT NOT NULL,
	area CHAR(3) NOT NULL,
	seccion CHAR(2) NOT NULL,
	precio DECIMAL(7, 2) NOT NULL,
	CONSTRAINT PK_Precios PRIMARY KEY(evento, area, seccion),
	CONSTRAINT FK_Precios_Eventos FOREIGN KEY(evento) REFERENCES [admin].[eventos](id),
	CONSTRAINT FK_Precios_SeccionesCtg FOREIGN KEY(seccion, area) REFERENCES [catalogo].[secciones_ctg](id, area),
	CONSTRAINT CHK_Precios_precio CHECK(precio < 5000)
);
CREATE TABLE [admin].[empleados](
	control SMALLINT NOT NULL identity(100, 1),
	apPaterno VARCHAR(25) NOT NULL,
	apMaterno VARCHAR(25),
	nombre VARCHAR(25) NOT NULL,
	fechaContratacion date,
	status CHAR(2) NOT NULL DEFAULT 'UP',
	CONSTRAINT PK_Empleados PRIMARY KEY(control),
	CONSTRAINT CHK_Empleados_status CHECK(status IN('UP', 'DW'))
);
CREATE TABLE [ventas].[ventas](
	numero CHAR(12) NOT NULL,
	fechaHora DATETIME NOT NULL DEFAULT GETDATE(),
	vendedor smallint NOT NULL,
	CONSTRAINT PK_Ventas PRIMARY KEY(numero),
	CONSTRAINT FK_Ventas_Empleados FOREIGN KEY(vendedor) REFERENCES [admin].[empleados](control),
	CONSTRAINT CHK_Boletos_fechaHora CHECK(fechaHora = GETDATE())
);
CREATE TABLE [ventas].[boletos](
	folio VARCHAR(20) NOT NULL,
	venta CHAR(12) NOT NULL,
	evento INT NOT NULL,
	area CHAR(3) NOT NULL,
	seccion CHAR(2) NOT NULL,
	butaca VARCHAR(5) NOT NULL,
	CONSTRAINT PK_Boletos PRIMARY KEY(folio, evento, area, seccion, butaca),
	CONSTRAINT FK_Boletos_Ventas FOREIGN KEY(venta) REFERENCES [ventas].[ventas](numero),
	CONSTRAINT FK_Boletos_Eventos FOREIGN KEY(evento) REFERENCES [admin].[eventos](id),
	CONSTRAINT FK_Boletos_SeccionesCtg FOREIGN KEY(seccion, area) REFERENCES [catalogo].[secciones_ctg](id, area),
	CONSTRAINT UQ_Boletos_folio UNIQUE(folio)
);
CREATE TABLE [admin].[perfiles_ctg](
	clave CHAR(2) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	CONSTRAINT PK_PerfilesCtg PRIMARY KEY(clave)
);
CREATE TABLE [admin].[usuarios](
	empleado SMALLINT NOT NULL,
	perfil CHAR(2) NOT NULL,
	nombre VARCHAR(15) NOT NULL,
	contrasena VARCHAR(50) NOT NULL,
	status CHAR(2) NOT NULL DEFAULT 'UP',
	CONSTRAINT PK_Usuarios PRIMARY KEY(empleado),
	CONSTRAINT FK_Usuarios_PerfilesCtg FOREIGN KEY(perfil) REFERENCES [admin].[perfiles_ctg](clave),
	CONSTRAINT FK_Usuarios_Empleados FOREIGN KEY(empleado) REFERENCES [admin].[empleados](control),
	CONSTRAINT CHK_Usuarios_status CHECK(status IN('UP', 'DW'))
);

--Crear Rol de Administrador
CREATE ROLE Administrador

--Permisos de la tabla boletos
GRANT SELECT ON OBJECT::[ventas].[boletos] TO Administrador
GRANT UPDATE ON OBJECT::[ventas].[boletos] TO Administrador
GRANT INSERT ON OBJECT::[ventas].[boletos] TO Administrador
GRANT DELETE ON OBJECT::[ventas].[boletos] TO Administrador

--Permisos de la tabla empleados
GRANT SELECT ON OBJECT::[admin].[empleados] TO Administrador
GRANT UPDATE ON OBJECT::[admin].[empleados] TO Administrador
GRANT INSERT ON OBJECT::[admin].[empleados] TO Administrador

--Permisos de la tabla eventos
GRANT SELECT ON OBJECT::[admin].[eventos] TO Administrador
GRANT UPDATE ON OBJECT::[admin].[eventos] TO Administrador
GRANT INSERT ON OBJECT::[admin].[eventos] TO Administrador

--Permisos de la tabla precios
GRANT SELECT ON OBJECT::[admin].[precios] TO Administrador
GRANT UPDATE ON OBJECT::[admin].[precios] TO Administrador
GRANT INSERT ON OBJECT::[admin].[precios] TO Administrador

--Permisos de la tabla usuarios
GRANT SELECT ON OBJECT::[admin].[usuarios] TO Administrador
GRANT UPDATE ON OBJECT::[admin].[usuarios] TO Administrador
GRANT INSERT ON OBJECT::[admin].[usuarios] TO Administrador

--Permisos de la tabla ventas
GRANT SELECT ON OBJECT::[ventas].[ventas] TO Administrador
GRANT UPDATE ON OBJECT::[ventas].[ventas] TO Administrador
GRANT INSERT ON OBJECT::[ventas].[ventas] TO Administrador

CREATE ROLE VendedorBoletos

--Permisos de la tabla boletos
GRANT SELECT ON OBJECT::[ventas].[boletos] TO VendedorBoletos
GRANT INSERT ON OBJECT::[ventas].[boletos] TO VendedorBoletos

--Permisos de la tabla Eventos
GRANT SELECT ON OBJECT::[admin].[eventos] TO VendedorBoletos

--Permisos de la tabla de usuarios
GRANT SELECT ON OBJECT::[admin].[eventos] TO VendedorBoletos

--Permisos de la tabla de usuarios
GRANT SELECT ON OBJECT::[catalogo].[areas_ctg] TO VendedorBoletos

--Permisos de la tabla de usuarios
GRANT SELECT ON OBJECT::[catalogo].[secciones_ctg] TO VendedorBoletos


GO
go
INSERT INTO admin.perfiles_ctg(clave, nombre) values
('AD','Administrador'),
('VB','Taquillero');
go
GO

-- Creacion del SP
create procedure usp_iUsuarios
    @usuario varchar(15),
    @contrasena varchar(20),
    @apMaterno varchar(25),
    @apPaterno varchar(25),
    @nombre varchar(25),
    @perfil char(2),
    @respuesta nvarchar(250) output
as
begin
    set nocount on

    begin try
		-- Primero inserta al empleado
		INSERT INTO ADMIN.empleados(apPaterno, apMaterno, nombre, status, fechaContratacion) values
		(@apPaterno, @apMaterno, @nombre, 'UP', GETDATE());
		--Luego buscamos el ID del empleado que se acaba de insertar
		declare @newID int = 0;
		SELECT @newID += @@IDENTITY;
		--select @newID;
		--Inserta al usuario
		insert into admin.usuarios (empleado, perfil ,nombre, contrasena, status) values
		(@newID, @perfil ,@usuario, hashbytes('sha1', @contrasena), 'UP')
		set @respuesta = 'Registro exitoso'
    end try
    begin catch
        set @respuesta = error_message() 
    end catch
end
GO

declare @respuesta varchar(250)
exec usp_iUsuarios 'ejemplo', '1234567', 'ejemplo', 'ejemplote', 'ejemplito','VB', @respuesta output
select respuesta = @respuesta

GO

-- Creacion del SP
create procedure usp_sUsuarios
	@usuario varchar(254),
    @contrasena varchar(50),
    @respuesta varchar(250) output
as
begin
	-- Declaracion de variables
    set nocount on
    declare @id int
	-- Valida si existe un usuario bajo el nombre de usuario indicado
    if exists (select top 1 empleado from admin.usuarios where nombre = @usuario)
    begin
		-- Se asigna el 'id' del usuario que haga 'match' entre usuario y (contrasena + 'salt') encriptada 
		set @id = (select empleado from admin.usuarios where nombre = @usuario and contrasena = hashbytes('sha1', @contrasena))
		if(@id is not null)
			set @respuesta = 'Acceso autorizado'
		else
			set @respuesta = 'Usuario o contraseņa incorrecto'
    end
end
GO
-- SP en accion
declare @respuesta varchar(250)
exec usp_sUsuarios 'ejemplo', '1234567', @respuesta out
select respuesta = @respuesta
GO


select * from admin.usuarios

select * from admin.empleados

select control, apPaterno, apMaterno, nombre, fechaContratacion
from admin.empleados
where control = 100

select perfil, nombre, status 
from admin.usuarios 
where empleado = 100

select * from admin.perfiles_ctg

select clave, nombre
from admin.perfiles_ctg
where clave = 'AD'