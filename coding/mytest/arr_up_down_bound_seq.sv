module arr_bound ();

int a [3];
int b [2:0];
int c [0:2];
int d [3];

  initial begin
    for (int i = 0;i<3 ;i++ ) begin
      a[i]=i;
    end
    b=a;
    c=a;
    d=a;
    for (int i = 0;i<3 ;i++ ) begin
      $display("a[%0d]:%0d b[%0d]:%0d c[%0d]:%0d d[%0d]:%0d",i,a[i],i,b[i],i,c[i],i,d[i]);
    end
  end

endmodule