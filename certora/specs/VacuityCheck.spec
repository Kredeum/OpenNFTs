rule VacuityCheck(method f) {
	env e; calldataarg args;
	f(e, args);
	assert true;
}