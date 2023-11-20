`include "scores_sort_v2.pkg"
module score_sort_v2(); 
	int num=19;// the number of the  student
	Student_t Student[]; //dynamic array statement

	initial begin
		Student = new[num];
		Student[0] = {"zhangsan", "20230001",{100,94,90,75,99,77}, 1,0};
		Student[1] = {"lisi", "20230002",{60,68,50,60,51,80}, 0,0};
		Student[2] = {"wangyu", "20230003",{91,78,88,87,99,50}, 1,0};
		Student[3] = {"jack", "20230004",{50,78,67,60,80,77}, 0,0};
		Student[4] = {"Rose", "20230005",{61,98,55,75,80,77}, 0,0};
		Student[5] = {"Horse", "20230006",{50,87,70,75,89,77}, 1,0};
		Student[6] = {"Judy", "20230007",{40,91,90,75,59,77}, 0,0};
		Student[7] = {"Cristina", "20230008",{40,48,90,75,79,77}, 1,0};
		Student[8] = {"Antonio", "20230009",{66,66,90,75,19,77}, 1,0};
		Student[9] = {"MA_YOYO", "20230010",{77,66,90,75,69,77}, 0,0};
		Student[10] = {"Edward Yang", "20230011",{50,56,90,75,49,77}, 1,0};
		Student[11] = {"Li an", "20230012",{60,87,90,75,69,77}, 1,0};
		Student[12] = {"Zhangyimo", "20230013",{60,67,90,75,69,77}, 0,0};
		Student[13] = {"ZHoudongyu", "20230014",{80,86,90,75,49,77}, 0,0};
		Student[14] = {"Yangying", "20230015",{60,80,45,75,89,77}, 1,0};
		Student[15] = {"Huangxiaoming", "20230016",{98,41,90,75,59,77}, 1,0};
		Student[16] = {"Jianailiang", "20230017",{78,77,90,75,79,77}, 0,0};
		Student[17] = {"Zhuneiliang", "20230018",{89,94,90,75,49,77}, 0,0};
		Student[18] = {"Sheildon", "20230019",{100,100,100,100,99,99}, 1,0};
		for(int i=0; i<num; i++)begin
			for(int j=0; j<6; j++)begin
				Student[i].total +=  Student[i].score[j];		//caculate the total score
			end	
		end	
	 
	 	sort(Student, num);
		print(Student, num);
	end

endmodule