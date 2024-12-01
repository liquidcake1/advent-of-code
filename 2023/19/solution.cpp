#include <iostream>
#include <sstream>
#include <vector>
#include <queue>
#include <csignal>
#include <map>

using namespace std;
char names[4] = {'x', 'm', 'a', 's'};

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
class PartRange {
	public:
		int lows[4];
		int highs[4];
		string at;
		PartRange(int inlows[4], int inhighs[4], string inat) {
			for(int i=0; i<4; i++) {
				lows[i] = inlows[i];
				highs[i] = inhighs[i];
			}
			at = inat;
		}
		PartRange(const PartRange &pr) {
			for(int i=0; i<4; i++) {
				lows[i] = pr.lows[i];
				highs[i] = pr.highs[i];
			}
			at = pr.at;
		}
		void out(ostream& os) const {
			os << at << ":";
			char sep = '{';
			for(int i=0; i<4; i++) {
				os << sep << lows[i] << "<=" << names[i] << "<=" << highs[i];
				sep = ',';
			}
			os << '}';
		}
		long long count() const {
			long long ans = 1;
			for(int i=0; i<4; i++) {
				if (lows[i] <= highs[i]) {
					ans *= highs[i] - lows[i] + 1;
				} else {
					return 0;
				}
			}
			return ans;
		}
};
std::ostream & operator<<(std::ostream & os, const PartRange &pr) {
	pr.out(os);
	return os;
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
				os << names[var] << (isgt ? ">" : "<") << val << ":" << dest;
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
		void split_out(PartRange &in, queue<PartRange> &out) {
			if (isop) {
				if (isgt) {
					if (in.highs[var] > val) {
						PartRange n(in);
						in.highs[var] = val;
						n.lows[var] = val + 1;
						cout << "postsplit " << in << endl;
						cout << "test queue " << n << " " << n.count() << endl;
						if (n.count() > 0) {
							cout << "queue " << n << endl;
							n.at = dest;
							out.push(n);
						}
					} else {
						cout << "nomatch" << endl;
					}
				} else {
					if (in.lows[var] < val) {
						PartRange n(in);
						in.lows[var] = val;
						n.highs[var] = val - 1;
						cout << "postsplit " << in << endl;
						cout << "test queue " << n << " " << n.count() << endl;
						if (n.count() > 0) {
							cout << "queue " << n << endl;
							n.at = dest;
							out.push(n);
						}
					} else {
						cout << "nomatch" << endl;
					}
				}
			} else {
				in.at = dest;
				out.push(in);
				in.lows[0] = in.highs[0] - 1;
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
		void split_out(PartRange pr, queue<PartRange> &out) {
			for(auto rule: rules) {
				cout << "Inspecting " << rule << endl;
				if (pr.count() == 0) {
					cout << "Nothing left" << endl;
					return;
				}
				rule.split_out(pr, out);
			}
		}

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
	// Part 1
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
	// Part 2
	queue<PartRange> parts;
	parts.push(PartRange(new int[4] {1, 1, 1, 1}, new int[4] {4000, 4000, 4000, 4000}, "in"));
	long long ans2 = 0;
	while(parts.size() > 0) {
		PartRange pr = parts.front();
		parts.pop();
		cout << "Processing " << pr << endl;
		if (pr.at == "A") {
			ans2 += pr.count();
			cout << "Ans2 is " << ans2 << endl;
			continue;
		} else if (pr.at == "R") {
			continue;
		}
		workflows.at(pr.at).split_out(pr, parts);
		cout << "Queue size is " << parts.size() << endl;
	}
	cout << "Part 1 is " << ans << endl;
	cout << "Part 2 is " << ans2 << endl;
}

