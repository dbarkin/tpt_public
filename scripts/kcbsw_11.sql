SELECT * FROM (
	SELECT 
		dsc.kcbwhdes,
		why.why0, 
		why.why1,
		why.why2,
		sw.other_wait
	FROM
		x$kcbuwhy	why,
		x$kcbwh		dsc,
		x$kcbsw		sw
	WHERE
		why.indx = dsc.indx
	AND	why.why0 + why.why1 + why.why2 + sw.other_wait > 0
	AND dsc.indx = sw.indx
	AND why.indx = sw.indx
	ORDER by
	--	dsc.kcbwhdes
		why.why0 + why.why1 + why.why2 ASC
)
--WHERE rownum <= 10
/
