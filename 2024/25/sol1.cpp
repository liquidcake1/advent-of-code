#include <iostream>
#include <string>
#include <vector>

using namespace std;

int main(int argc, char **argv) {
  string line;
  vector<vector<int>> keys;
  vector<vector<int>> locks;
  int common_width = 0;
  int common_height = 0;
  while(!cin.eof()) {
    vector<int> *item;
    int height = 0;
    while (!cin.eof()) {
      getline(cin, line);
      if (line.empty()) break;
      if (height == 0) {
        vector<vector<int>> *input;
        if (line[0] == '#')
          input = &locks;
        else
          input = &keys;
        input->push_back(vector<int>(line.length()));
        item = &input->back();
      }
      height++;
      for (int i=0; i<line.length(); i++) {
        if (line[i] == '#')
          (item->at(i))++;
      }
    }
    if (height == 0) break;
    if (common_width == 0)
      common_width = item->size();
    if (common_width != item->size())
      cerr << "Oh no width!" << endl;
    if (common_height == 0)
      common_height = height;
    if (common_height != height)
      cout << "Oh no height!" << endl;
    //cout << "Item of width " << item->size() << " and height " << height << " created.\n";
  }
  int count = 0;
  for (vector<int> key: keys) {
    for (vector<int> lock: locks) {
      bool ok = true;
      for (int i=0; i<key.size(); i++) {
        if (key[i] + lock[i] > common_height) {
          //cout << "Key " << key[i] << " lock " << lock[i] << " not ok" << endl;
          ok = false;
        }
      }
      if (ok) count++;
    }
  }
  cout << count << endl;
}
