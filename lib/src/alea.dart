part of deskovka_libs.base;

class Alea {
  int damage = 0;
  List<int> attack = null;
  List<int> nums = [];

  Alea(this.attack) {
   nums = [(random.nextDouble() * 6).floor(),(random.nextDouble() * 6).floor()];
  }

  int getDamage(){
    int out = attack[nums.first];
    if(nums.first==5){
      out+=nums[1];
    }
    return out;
  }
}
