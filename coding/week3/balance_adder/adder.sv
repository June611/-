module aatest();
     int array[6] ='{0,1,2,3,4,5};
function automatic int b_add( int lo,  hi);
	int mid = (lo+hi+1)>>1;
	$display("lo is %d, hi is %d",lo ,hi);
	 if(lo==hi)
		return(array[0]);
	else if(lo+1 !=hi)
		return(b_add( lo, (mid-1))+b_add(mid,hi));
	else
		return(array[lo] + array[hi]);
	
endfunction

initial
begin
	automatic int c=0;
	c=b_add(0,4);
	$display("c %d", c);
end
endmodule