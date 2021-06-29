class personal_trainer_item
{
  String mem_id,mem_name,join_date,exp_date,balance,pt_name;

  personal_trainer_item(this.mem_id, this.mem_name, this.join_date,
      this.exp_date, this.balance, this.pt_name);

  personal_trainer_item.fromJson(Map<String,dynamic> json)
  {
    mem_id=json['mem_id'];
    mem_name=json['mem_name'];
    join_date=json['join_date'];
    exp_date=json['exp_date'];
    balance=json['balance'];
    pt_name=json['pt_name'];
  }

  Map<String,dynamic> tojson()
  {
    final Map<String,dynamic> data=new Map<String,dynamic>();
    data['mem_id']=this.mem_id;
    data['mem_name']=this.mem_name;
    data['join_date']=this.join_date;
    data['exp_date']=this.exp_date;
    data['balance']=this.balance;
    data['pt_name']=this.pt_name;
  }
}