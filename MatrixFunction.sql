-- drop function if exists matrixMultiply;
-- create function matrixMultiply(mtx1 numeric[], mtx2 numeric[]) returns numeric[][] as
-- $$
-- declare
-- 	i integer;
-- 	j integer;
-- 	rowNum integer;
-- 	colNum integer;
-- 	product numeric(20,10)[][];
-- begin
-- 	rowNum = array_length(mtx1, 1);
-- 	colNum = array_length(mtx2, 1);
-- 	product = array_fill(0, array[rowNum, colNum]);
-- 	i = 1;
-- 	loop exit when i > rowNum;
-- 		j = 1;
-- 		loop exit when j > colNum;
--  			product[i][j] = vectorMultiply(mtx1[i:i][:], mtx2[j:j][:]);
-- 			j = j + 1;
-- 		end loop;
-- 		i = i + 1;
-- 	end loop;

-- 	return product;
-- end;
-- $$
-- language plpgsql;							   

drop function if exists matrixMultiply;
create function matrixMultiply(mtx1 numeric[], mtx2 numeric[]) returns numeric[][] as
$$
declare
 	i integer;
 	j integer;
 	rowNum integer;
 	colNum integer;
 	product numeric(20,10)[][];
begin
	if array_length(mtx1, 2) != array_length(mtx2, 1) then
		raise exception 'matrix dimension mismatch';
	end if;
	
 	rowNum = array_length(mtx1, 1);
 	colNum = array_length(mtx2, 2);
 	product = array_fill(0, array[rowNum, colNum]);
 	i = 1;
 	loop exit when i > rowNum;
 		j = 1;
 		loop exit when j > colNum;
  			product[i][j] = vectorMultiply(mtx1[i:i][:], matrixTranspose(mtx2[:][j:j]));
 			j = j + 1;
 		end loop;
 		i = i + 1;
 	end loop;

 	return product;
end;
$$
language plpgsql;
	
drop function if exists squareLoss;
create function squareLoss(m1 numeric[], m2 numeric[]) returns numeric as
$$
declare
	loss numeric(20,10);
	i integer;
	j integer;
	lambda numeric;
begin
	i = 1;
	loss = 0.0;				 
	loop exit when i > array_length(m1, 1);
		j = 1;
		loop exit when j > array_length(m1, 2);
			if m1[i][j] != 0 then 
				loss = loss + power(m1[i][j] - m2[i][j], 2.0);
			end if;
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return loss;
end;
$$
language plpgsql;


drop function if exists l2norm;
create function l2norm(mtx numeric[]) returns numeric as 
$$
declare
	total numeric(20,10);
	i integer;
	j integer;
begin
	i = 1;
	total = 0.0;				 
	loop exit when i > array_length(mtx, 1);
		j = 1;
		loop exit when j > array_length(mtx, 2);
			total = total + power(mtx[i][j], 2.0);
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return total;
end;
$$
language plpgsql;

					   
drop function if exists vectorMultiply;
create function vectorMultiply(vec1 numeric[], vec2 numeric[]) returns numeric as
$$
declare
	total numeric(20,10);
	i integer;
	l integer;
begin
	l = array_length(vec1, 2);
	i = 1;
	total = 0;
	loop 
	exit when i > l;
		total = total + vec1[1][i] * vec2[1][i];
		i = i + 1;
	end loop;

	return total;
end;
$$
language plpgsql;


drop function if exists randomMatrix;
create function randomMatrix(rowNum integer, colNum integer) returns numeric[] as
$$
declare
	mtx numeric(20,10)[];
	i integer;
	j integer;
begin
	mtx = array_fill(0, array[rowNum, colNum]);
	i = 1;
	loop exit when i > rowNum;
		j = 1;
		loop exit when j > colNum;
			mtx[i][j] = random();
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return mtx;
end;
$$
language plpgsql;

drop function if exists matrixCopy;
create function matrixCopy(mtx numeric[]) returns numeric[] as
$$
declare
	mtxCopy numeric[];
	i integer;
	j integer;
	rowNum integer;
	colNum integer;
begin
	rowNum = array_length(mtx, 1);
	colNum = array_length(mtx, 2);
	mtxCopy = array_fill(0, array[rowNum, colNum]);
	i = 1;
	loop exit when i > rowNum;
		j = 1;
		loop exit when j > colNum;
			mtxCopy[i][j] = mtx[i][j];
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return mtxCopy;
end;
$$
language plpgsql;

drop function if exists matrixAddition;
create function matrixAddition(mtx1 numeric[], mtx2 numeric[], sign integer) returns numeric[] as
$$
declare 
	i integer;
	j integer;
	rowNum integer;			
	colNum integer;	
	res numeric[];
begin
	rowNum = array_length(mtx1, 1);
	colNum = array_length(mtx1, 2);
	res = array_fill(0, array[rowNum, colNum]);
	i = 1;
	loop exit when i > rowNum;
		j = 1;
		loop exit when j > colNum;
			res[i][j] = mtx1[i][j] + sign * mtx2[i][j];
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return res;	
end;	
$$	
language plpgsql;
							  
drop function if exists matrixTranspose;						  
create function matrixTranspose(mtx numeric[]) returns numeric[] as									  
$$							  
declare							  
	i integer;
	j integer;
	rowNum integer;			
	colNum integer;	
	res numeric[];
begin
	rowNum = array_length(mtx, 1);
	colNum = array_length(mtx, 2);
	res = array_fill(0, array[colNum, rowNum]);
	i = 1;
	loop exit when i > rowNum;
		j = 1;
		loop exit when j > colNum;
			res[j][i] = mtx[i][j];
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return res;					  
end;						  
$$						  
language plpgsql;							  
							  
							  
							  
drop function if exists matrixSubstitute;						  
create function matrixSubstitute(mtx1 numeric[], mtx2 numeric[], val numeric) returns numeric[] as									  
$$							  
declare							  
	i integer;
	j integer;
	rowNum integer;			
	colNum integer;	
	res numeric[];
begin
	rowNum = array_length(mtx1, 1);
	colNum = array_length(mtx1, 2);
	res = array_fill(0, array[rowNum, colNum]);
	i = 1;
	loop exit when i > rowNum;
		j = 1;
		loop exit when j > colNum;
	    
			if mtx2[i][j] = val then
				res[i][j] = mtx2[i][j];
			else
				res[i][j] = mtx1[i][j];
			end if;
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return res;					  
end;						  
$$						  
language plpgsql;							  
							  
drop function if exists matrixScale;							  
create function matrixScale(mtx numeric[], num numeric) returns numeric[] as							  
$$
declare 
	i integer;
	j integer;
	rowNum integer;			
	colNum integer;	
	res numeric[];
begin
	rowNum = array_length(mtx, 1);
	colNum = array_length(mtx, 2);
	res = array_fill(0, array[rowNum, colNum]);
	i = 1;
	loop exit when i > rowNum;
		j = 1;
		loop exit when j > colNum;
			res[i][j] = mtx[i][j] * num;
			j = j + 1;
		end loop;
		i = i + 1;
	end loop;
	return res;	
end;	
$$	
language plpgsql;							  
							  
							  
							  
							  
							  
							  
							  
							  
