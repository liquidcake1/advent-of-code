#include <iostream>
#include <sstream>
#include <vector>
#include <csignal>
#include <map>

using namespace std;

char parse_prop(char c) {
	switch(c) {
		case 'x': return 0;
		case 'm': return 1;
		case 'a': return 2;
		case 's': return 3;
		default:
			cerr << "Bad prop " << c << " " << (int)c << endl;
			raise(SIGTERM);
	}
	return -1;
}
class Part {
	public:
		int vals[4];
		Part(string s) {
			int osplit = 1, split;
			while ((split = s.find_first_of("},", osplit)) != string::npos) {
				int part_idx = parse_prop(s[osplit]);
				int val = stoi(s.substr(osplit+2, split-osplit-2));
				vals[part_idx] = val;
				osplit=split+1;
			}
		}
		void out(ostream& os) const {
			char sep = '{';
			char names[4] = {'x', 'm', 'a', 's'};
			for(int i=0; i<4; i++) {
				os << sep << names[i] << '=' << vals[i];
				sep = ',';
			}
			os << '}';
		}
};
std::ostream & operator<<(std::ostream & os, const Part &p) {
	p.out(os);
	return os;
}
class Rule {
	char var;
	bool isop;
	bool isgt;
	int val;
	public:
		string dest;
		Rule(string s) {
			if (s[1] == '<' || s[1] == '>') {
				isop = true;
				var = parse_prop(s[0]);
				isgt = s[1] == '>';
				int colon = s.find(':', 3);
				val = stoi(s.substr(2, colon));
				dest = s.substr(colon + 1);
			} else {
				isop = false;
				dest = s;
			}
		}
		string toString() {
			stringstream ss;
			out(ss);
			return ss.str();
		}
		void out(std::ostream& os) const {
			if (isop) {
				os << var << (isgt ? ">" : "<") << val << ":" << dest;
			} else {
				os << dest;
			}
		}
		bool match(const Part& p) const {
			if (isop) {
				int tocompare = p.vals[var];
				if (isgt) {
					return tocompare > val;
				} else {
					return tocompare < val;
				}
			} else {
				return true;
			}
		}
};
std::ostream & operator<<(std::ostream & os, const Rule &r) {
	r.out(os);
	return os;
}
class Workflow {
	vector<Rule> rules;
	public:
		string name;
		Workflow(string s) {
			int split = s.find('{');
			name = s.substr(0, split);
			int osplit = split + 1;
			while ((split = s.find_first_of("},", osplit)) != string::npos) {
				rules.push_back(Rule(s.substr(osplit, split - osplit)));
				osplit = split + 1;
			}
		}
		void out(ostream& os) const {
			os << name;
			char sep = '{';
			for(auto rule: rules) {
				os << sep << rule;
				sep = ',';
			}
			os << "}";
		}
		string next(const Part p) {
			for(auto rule: rules) {
				if (rule.match(p)) {
					return rule.dest;
				}
			}
			cerr << "Workflow " << this << " does not match part " << p << endl;
			raise(SIGTERM);
			return "";
		};
};
std::ostream & operator<<(std::ostream & os, const Workflow &w) {
	w.out(os);
	return os;
}
int main (int argc, char **argv) {
	string s;
	map<string, Workflow> workflows;
	while(getline(cin, s), s.length() > 0) {
		Workflow w(s);
		workflows.emplace(w.name, w);
		cout << "workflow " << w << endl;

	}
	int ans = 0;
	while(getline(cin, s), s.length() > 0) {
		Part p(s);
		cout << "part " << s << endl;
		string current("in");
		while(current != "R" && current != "A") {
			cout << "At " << current << endl;
			current = workflows.at(current).next(p);
		}
		cout << "Finish at " << current << endl;
		if (current == "A") {
			for (auto i: p.vals) {
				ans += i;
			}
		}
		cout << "Ans is " << ans << endl;
	}
}

