drop function if exists matrixFactorization;
create function matrixFactorization() returns void as
$$
declare
	e numeric(15,10);
	loss numeric(15,10);
	alpha numeric(15,10);
	lambda numeric(15,10);
	gradient numeric(15,10);
	threshold numeric(15,10);
	regularizer numeric(20, 10);
	trainingError numeric(20, 10);
	mtx numeric(15,10)[][];
	emtx numeric(15,10)[][];
	pmtx numeric(15,10)[][];
	umtx numeric(15,10)[][];
	bmtx numeric(15,10)[][];
	umtxTmp numeric(15,10)[][];
	bmtxTmp numeric(15,10)[][];
	ulist text[];
	blist text[];
	unum integer;
	bnum integer;
	fsize integer;
	i integer;
	j integer;
	l integer;
	iter integer;
	query text;
begin
 	fsize = 20;
 	unum = 500;
 	bnum = 100;
 	alpha = 0.0005;
 	lambda = 0.01;
 	umtx = randomMatrix(unum,fsize);
 	bmtx = randomMatrix(fsize, bnum);
	umtxTmp = matrixCopy(umtx);
	bmtxTmp = matrixCopy(bmtx);
-- 	mtx = array[[5.0,3.0,0.0,1.0,4.0],[4.0,0.0,0.0,1.0,1.0],[1.0,1.0,0.0,5.0,4.0],[1.0,0.0,0.0,4.0,0.0],[0.0,1.0,5.0,4.0,0.0]];
  	execute 'select array_agg(review) from user_review_matrix;' into mtx;
 	iter = 1;
	pmtx = matrixMultiply(umtx, bmtx);

	loop exit when iter > 5;
        pmtx = matrixMultiply(umtx, bmtx);
        pmtx = matrixSubstitute(pmtx, mtx, 0);
        emtx = matrixAddition(mtx, pmtx, -1);
        umtx = matrixAddition(umtx, matrixScale(matrixAddition(matrixScale(matrixMultiply(emtx, matrixTranspose(bmtx)), -2), matrixScale(umtx, 2*lambda), 1), alpha), -1);
        bmtx = matrixAddition(bmtx, matrixScale(matrixAddition(matrixScale(matrixMultiply(matrixTranspose(umtx), emtx), -2), matrixScale(bmtx, 2*lambda), 1), alpha), -1);
		
		pmtx = matrixMultiply(umtx, bmtx);
        pmtx = matrixSubstitute(pmtx, mtx, 0);
        emtx = matrixAddition(mtx, pmtx, -1);
		trainingError = 0;
		regularizer = 0;																							  
		
		trainingError = l2norm(emtx);
		regularizer = (l2norm(umtx) + l2norm(bmtx)) * lambda * 30;
		raise notice 'Iter: %, Loss: %', iter, trainingError + regularizer;
		raise notice 'TrainingError: %, Regularizer: %', trainingError, regularizer;																					 
		iter = iter + 1;
	
		if abs((trainingError + regularizer - loss)/loss) < 0.00001 then
			exit;
		end if;
		loss = trainingError + regularizer;
	end loop;
	
	-- save result
	pmtx = matrixMultiply(umtx, bmtx);
	execute 'delete from user_recommend_table';
	execute 'select array_agg(business_id) from (select distinct business_id from user_review_micro order by business_id) tmp;' into blist;
	execute 'select array_agg(user_id) from (select distinct user_id from user_review_micro order by user_id) tmp;' into ulist;

	i = 1;
	loop exit when i > unum;
		j = 1;
		loop exit when j > bnum;
			query = 'insert into user_recommend_table values (' || quote_literal(ulist[i]) || ', ' || quote_literal(blist[j]) || ', ' || pmtx[i][j] || ');';
			execute query;
			j = j + 1; 
		end loop;
		i = i + 1;
	end loop;
	
	-- save checkpoint
	insert into training_checkpoint values ('umtx', umtx, iter);
	insert into training_checkpoint values ('bmtx', bmtx, iter);
	return;
end;
$$
language plpgsql;







						   