drop table historial_laboral;
drop table empleados;

CREATE TABLE empleados (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  apellido VARCHAR(255) NOT NULL,
  cargo VARCHAR(255) NOT NULL,
  fecha_ingreso DATE NOT null,
  salario FLOAT not null
);

CREATE TABLE historial_laboral (
  id SERIAL PRIMARY KEY,
  id_empleado INTEGER NOT NULL REFERENCES empleados(id),
  cargo VARCHAR(255) not NULL,
  fecha_fin DATE NULL,
  fecha_inicio DATE NOT NULL
);

CREATE OR REPLACE FUNCTION historial_laboral_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historial_laboral (id_empleado, cargo, fecha_inicio)
    VALUES (NEW.id, NEW.cargo, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER historial_laboral_insert
AFTER INSERT
ON empleados
FOR EACH ROW
EXECUTE FUNCTION historial_laboral_insert_trigger();

CREATE OR REPLACE FUNCTION actualizar_cargo_function() RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.cargo <> NEW.cargo THEN
            UPDATE historial_laboral
            SET fecha_fin = NOW()
            WHERE id_empleado = OLD.id
            AND cargo = OLD.cargo
            AND fecha_fin IS NULL;

            INSERT INTO historial_laboral (id_empleado, cargo, fecha_inicio)
            VALUES (OLD.id, new.cargo, NOW());
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER actualizar_cargo
AFTER UPDATE
ON empleados
FOR EACH ROW
EXECUTE FUNCTION actualizar_cargo_function();

INSERT INTO empleados (nombre, apellido, cargo, fecha_ingreso, salario)
VALUES ('Juan', 'Pérez', 'Analista de Datos', '2023-01-01', 1800000);

select * from empleados e;
select * from historial_laboral hl;

UPDATE empleados
SET cargo = 'Gerente de Proyectos'
  , salario = 5000000
WHERE id = 1;

select * from historial_laboral hl;

CREATE OR REPLACE FUNCTION obtener_empleados_por_cargo_salario(nombre_cargo VARCHAR, salario_min INT DEFAULT 0)
RETURNS TABLE(id_empleado INT, empleado VARCHAR) AS 
$$
	BEGIN
		RETURN QUERY 
			SELECT id
				 , nombre
			FROM empleados 
			WHERE cargo = nombre_cargo 
			  AND salario >= salario_min
			;
	END;
$$ LANGUAGE plpgsql;

select * from obtener_empleados_por_cargo('Ingeniero de Datos');
select * from obtener_empleados_por_cargo_salario('Ingeniero de Datos', 1000000);


CREATE OR REPLACE FUNCTION suma(a INT, b INT)
RETURNS INT AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql
