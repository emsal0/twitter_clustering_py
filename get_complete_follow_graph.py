from get_followers import get_follow_list
import sys

def get_complete_follow_graph(filename, your_username, your_password):

    with open(filename, 'r') as f:
        lines = f.readlines()
        num_lines = len(lines)

        i = 0

        for line in lines:
            user = line.strip()
            print("Getting follow list for {}... ({}/{})".format(user, i, num_lines))
            user_follow_list = get_follow_list(user, your_username, your_password)
            with open("data/{}.txt".format(user), 'w') as user_data_file:
                user_data_file.write("\n".join(user_follow_list))

            i += 1


if __name__ == "__main__":
    get_complete_follow_graph(sys.argv[1], sys.argv[2], sys.argv[3])
