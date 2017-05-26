public Class checkRecursive{

    private static boolean run = true;

    public static boolean runOnce(){

    if(run){

     run=false;
     system.debug('checkrecursive-->>true');
     return true;

    }else{
        system.debug('checkrecursive-->>'+run);
        return run;

    }

    }

}